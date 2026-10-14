
const { setGlobalOptions } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");

initializeApp();

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 10,
});

const db = getFirestore();

function requireAuthenticatedUser(request) {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must sign in to perform this action.",
    );
  }

  return request.auth;
}

function requireText(value, fieldName, maxLength = 1000) {
  if (
    typeof value !== "string" ||
    value.trim().length === 0 ||
    value.trim().length > maxLength
  ) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} is required and must be at most ${maxLength} characters.`,
    );
  }

  return value.trim();
}

async function getVerifiedProfile(uid) {
  const profile = await db.collection("users").doc(uid).get();

  if (!profile.exists) {
    throw new HttpsError(
      "permission-denied",
      "Your user profile was not found.",
    );
  }

  return profile.data();
}

// Employees report completed repair work.
// The machine remains unavailable until an admin verifies the report.
exports.reportRepair = onCall(async (request) => {
  const auth = requireAuthenticatedUser(request);
  const machineId = requireText(request.data?.machineId, "machineId", 128);
  const notes = requireText(request.data?.notes, "Repair notes", 2000);

  const profile = await getVerifiedProfile(auth.uid);

  if (profile.role !== "user") {
    throw new HttpsError(
      "permission-denied",
      "Only employees can submit repair reports.",
    );
  }

  const machineRef = db.collection("machines").doc(machineId);
  const repairRef = db.collection("repairRequests").doc();
  const historyRef = db.collection("workHistory").doc();

  await db.runTransaction(async (transaction) => {
    const machineSnapshot = await transaction.get(machineRef);

    if (!machineSnapshot.exists) {
      throw new HttpsError("not-found", "Machine not found.");
    }

    const machine = machineSnapshot.data();

    if (machine.status !== "Breakdown") {
      throw new HttpsError(
        "failed-precondition",
        "Only machines in Breakdown status can be reported as repaired.",
      );
    }

    const employeeEmail =
      typeof auth.token.email === "string"
        ? auth.token.email
        : profile.email || "";

    const eventData = {
      machineId,
      machineName: machine.machineName || machineId,
      action: "repair_submitted",
      previousStatus: machine.status,
      newStatus: "Pending Verification",
      employeeId: auth.uid,
      employeeEmail,
      notes,
      repairRequestId: repairRef.id,
      createdAt: FieldValue.serverTimestamp(),
    };

    transaction.create(repairRef, {
      machineId,
      machineName: machine.machineName || machineId,
      employeeId: auth.uid,
      employeeEmail,
      notes,
      previousStatus: machine.status,
      status: "Pending Verification",
      createdAt: FieldValue.serverTimestamp(),
    });

    transaction.update(machineRef, {
      status: "Pending Verification",
      pendingRepairRequestId: repairRef.id,
      updatedAt: FieldValue.serverTimestamp(),
    });

    transaction.create(historyRef, eventData);
  });

  logger.info("Repair submitted for verification", {
    machineId,
    employeeId: auth.uid,
    repairRequestId: repairRef.id,
  });

  return {
    success: true,
    repairRequestId: repairRef.id,
    status: "Pending Verification",
  };
});

// Only an admin can approve or reject a pending repair.
exports.reviewRepair = onCall(async (request) => {
  const auth = requireAuthenticatedUser(request);
  const repairRequestId = requireText(
    request.data?.repairRequestId,
    "repairRequestId",
    128,
  );
  const decision = request.data?.decision;
  const reviewNotes = (request.data?.notes ?? "").toString().trim();

  if (!["approve", "reject"].includes(decision)) {
    throw new HttpsError(
      "invalid-argument",
      "Decision must be approve or reject.",
    );
  }

  if (reviewNotes.length > 2000) {
    throw new HttpsError(
      "invalid-argument",
      "Review notes must be at most 2000 characters.",
    );
  }

  const profile = await getVerifiedProfile(auth.uid);

  if (profile.role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only administrators can review repair reports.",
    );
  }

  const repairRef = db.collection("repairRequests").doc(repairRequestId);
  const historyRef = db.collection("workHistory").doc();

  await db.runTransaction(async (transaction) => {
    const repairSnapshot = await transaction.get(repairRef);

    if (!repairSnapshot.exists) {
      throw new HttpsError("not-found", "Repair request not found.");
    }

    const repair = repairSnapshot.data();

    if (repair.status !== "Pending Verification") {
      throw new HttpsError(
        "failed-precondition",
        "This repair request has already been reviewed.",
      );
    }

    const machineRef = db.collection("machines").doc(repair.machineId);
    const machineSnapshot = await transaction.get(machineRef);

    if (!machineSnapshot.exists) {
      throw new HttpsError("not-found", "Machine not found.");
    }

    const machine = machineSnapshot.data();

    if (
      machine.status !== "Pending Verification" ||
      machine.pendingRepairRequestId !== repairRequestId
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Machine status no longer matches this repair request.",
      );
    }

    const approved = decision === "approve";
    const nextMachineStatus = approved ? "Running" : "Breakdown";
    const nextRequestStatus = approved ? "Approved" : "Rejected";
    const adminEmail =
      typeof auth.token.email === "string"
        ? auth.token.email
        : profile.email || "";

    transaction.update(machineRef, {
      status: nextMachineStatus,
      pendingRepairRequestId: FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
      ...(approved
        ? {
            lastFixedBy: repair.employeeId,
            lastFixedByEmail: repair.employeeEmail,
            lastFixedAt: repair.createdAt,
            verifiedBy: auth.uid,
            verifiedByEmail: adminEmail,
            verifiedAt: FieldValue.serverTimestamp(),
          }
        : {}),
    });

    transaction.update(repairRef, {
      status: nextRequestStatus,
      decision,
      reviewedBy: auth.uid,
      reviewedByEmail: adminEmail,
      reviewNotes,
      reviewedAt: FieldValue.serverTimestamp(),
    });

    transaction.create(historyRef, {
      machineId: repair.machineId,
      machineName: repair.machineName || repair.machineId,
      action: approved ? "repair_approved" : "repair_rejected",
      previousStatus: machine.status,
      newStatus: nextMachineStatus,
      employeeId: repair.employeeId,
      employeeEmail: repair.employeeEmail,
      reviewedBy: auth.uid,
      reviewedByEmail: adminEmail,
      repairRequestId,
      notes: reviewNotes,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  logger.info("Repair reviewed", {
    repairRequestId,
    decision,
    adminId: auth.uid,
  });

  return {
    success: true,
    status: decision === "approve" ? "Running" : "Breakdown",
  };
});
