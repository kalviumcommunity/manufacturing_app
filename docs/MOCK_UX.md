# Mock UX & Industrial Design System Specification
## ManufactureOS: UI/UX Architecture, Wireframes, Design Tokens, and Floor Ergonomics

---

### Document Control & Metadata
- **Document Version:** 1.0.0-PROD
- **Author:** Senior Staff UI/UX Systems Architect & Industrial Ergonomics Lead
- **Status:** Approved / Production Baseline
- **Target Environments:** Rugged Industrial Tablets (10"-12"), Handheld Floor Scanners (5.5"-6.5"), Supervisory Wall Consoles (24"-32")

---

## 1. Industrial Design Language & Tokens

Industrial floor environments present unique physical constraints: high-glare fluorescent and metal halide lighting, ambient vibrations, operators wearing heavy nitrile or leather safety gloves, and split-second cognitive decision-making needs. ManufactureOS is built from the ground up for high-contrast legibility, tactile feedback, and fail-safe interaction.

### 1.1 Color Tokens & Semantics (`lib/theme/app_theme.dart`)

```
+---------------------------------------------------------------------------------------+
|                             MANUFACTUREOS COLOR MATRIX                                |
+---------------------------------------------------------------------------------------+
|  Primary Carbon Slate   0xFF111827  Deep background, primary buttons, high contrast   |
|  Surface Card White     0xFFFFFFFF  High contrast card backgrounds against floor grit |
|  App Neutral Gray       0xFFF3F4F6  Factory background canvas (glare dampening)       |
|  Border Divider         0xFFE5E7EB  Crisp 1px card boundary definitions              |
|                                                                                       |
|  STATUS TOKENS:                                                                       |
|  Running Emerald        0xFF059669  Operating nominally, active line throughput       |
|  Maintenance Amber      0xFFD97706  Warning, inspection due, pending verification     |
|  Breakdown Crimson      0xFFDC2626  Critical stoppage, emergency halt, line blocked   |
+---------------------------------------------------------------------------------------+
```

| Token Name | Hex Code | Visual Application | WCAG Contrast Ratio |
| :--- | :--- | :--- | :---: |
| `AppColors.primary` | `#111827` | Brand badge, primary navigation items, header typography. | 14.8:1 (AAA) |
| `AppColors.background`| `#F3F4F6` | Master canvas surface dampening screen glare. | 1.1:1 (Canvas) |
| `AppColors.cardBg` | `#FFFFFF` | Isolated elevation cards and metric containers. | 18.2:1 (AAA) |
| `AppColors.running` | `#059669` | Pulsing running indicator, running filter chip, passed audits. | 7.4:1 (AAA) |
| `AppColors.maintenance`|`#D97706` | Pending verification badge, recurring fault warning, repair gate. | 8.1:1 (AAA) |
| `AppColors.breakdown` | `#DC2626` | Emergency stop card, breakdown line status, rejected work orders.| 8.6:1 (AAA) |
| `AppColors.border` | `#E5E7EB` | Micro-dividers and card outlines. | Structural |

---

### 1.2 Gloved Operation & Ergonomic Touch Targets

```
+-----------------------------------------------------------------------+
|                      MINIMUM TOUCH TARGET MATRIX                      |
+-----------------------------------------------------------------------+
|                                                                       |
|   +-----------------------+     Standard Mobile App: 36 x 36 dp       |
|   |      UNACCEPTABLE     |     (Causes mis-taps with work gloves)    |
|   +-----------------------+                                           |
|                                                                       |
|   +------------------------------------+                              |
|   |     MANUFACTUREOS STANDARD         | Minimum Target: 48 x 48 dp   |
|   |     (Gloved Palm & Finger Safe)    | Recommended:    54 x 54 dp   |
|   +------------------------------------+                              |
|                                                                       |
+-----------------------------------------------------------------------+
```

- **Buttons & Icon Links:** Minimum dimension $48 \times 48\text{ dp}$; primary quick-action buttons scaled to $54\text{ dp}$ height.
- **Card Tap Surfaces:** Entire container is an active hit target via `InkWell` wrapped in `Material(color: Colors.transparent)`.
- **Haptic Confirmations:** Critical emergency buttons provide immediate haptic feedback (`HapticFeedback.heavyImpact()`) upon physical registration.

---

## 2. Information Architecture & Navigation Topology

ManufactureOS features a dual-shell adaptive navigation model that reconfigures automatically based on the device width:

```mermaid
graph TD
    Root[AuthGate: Session Evaluation]
    Root -->|Unauthenticated| AuthScreen[AuthScreen: Floor Operator Sign-in]
    Root -->|Authenticated| DashShell[DashboardScreen: Master Responsive Shell]

    subgraph Navigation Shell [Adaptive Navigation Shell]
        DashShell -->|Width < 768px| BottomNav[Bottom Navigation Bar: 4 Destinations]
        DashShell -->|Width >= 768px| SideMenu[DashboardSidebar: Collapsible Scrollable Menu]
    end

    subgraph Core Views [Primary Screen Destinations]
        DashShell --> ViewOverview[DashboardHomeContent: KPI Grid & Quick Actions]
        DashShell --> ViewLines[AllProductionLinesScreen: Work Cell Health]
        DashShell --> ViewMachines[AllMachinesScreen: Equipment Inventory]
        DashShell --> ViewBreakdowns[AllBreakdownsScreen: Stoppage Tickets]
        DashShell --> ViewInspections[AllInspectionsScreen: Audit Logs]
        DashShell --> ViewFaults[RecurringFaultsScreen: Frequency Analytics]
        DashShell --> ViewAdmin[AdminScreen: Asset Provisioning & Approvals]
    end

    subgraph Detail & Action Flow [Contextual Navigation]
        ViewLines --> ScreenMachineList[MachineListScreen: Line Equipment]
        ScreenMachineList --> ScreenDetails[MachineDetailsScreen: Live Telemetry]
        ViewMachines --> ScreenDetails
        ScreenDetails --> ModalBreakdown[BreakdownForm: Report Stoppage]
        ScreenDetails --> ModalRepair[ReportRepairDialog: Submit Work Order]
        ViewAdmin --> ModalReview[ReviewRepairDialog: Approve/Reject Signoff]
    end
```

---

## 3. High-Fidelity ASCII Wireframes

### 3.1 Screen 1: Dashboard Home Overview (Desktop / Supervisory Console)

```
+----------------------------------------------------------------------------------------------------------------------+
| [O] ManufactureOS  EQUIPMENT NETWORK                                        Shift 1 (06:00 - 14:00)  [dheer@plant] [LOGOUT]|
+-------------------+--------------------------------------------------------------------------------------------------+
|                   |  +--------------------------------------------------------------------------------------------+  |
| MAIN MENU         |  | Welcome back, Dheer Jain (Plant Lead)                                                      |  |
|                   |  | Main Assembly Floor · 4 Production Lines Active · 48 Registered Equipment Units            |  |
| [*] Dashboard     |  +--------------------------------------------------------------------------------------------+  |
| [ ] Machines      |                                                                                                  |
| [ ] Lines (NEW)   |  [ ! WARNING: 2 Machine(s) with Recurring Breakdown Faults Detected ]        [ VIEW PATTERNS -> ]|  |
| [ ] Breakdowns    |                                                                                                  |
| [ ] Inspections   |  CURRENT PLANT TELEMETRY                                                                         |
| [ ] Fault Patterns|  +-------------------+  +-------------------+  +-------------------+  +-----------------------+  |
| [ ] Settings      |  | TOTAL EQUIPMENT   |  | RUNNING NORMALLY  |  | MAINTENANCE DUE   |  | ACTIVE BREAKDOWNS     |  |
|                   |  |      48 Units     |  |      42 Units     |  |       3 Units     |  |        3 Stoppages     |  |
| ----------------- |  | 87.5% Throughput  |  | [O] Emerald Pulse |  | [!] Pending Review|  | [X] Critical Halt      |  |
|                   |  +-------------------+  +-------------------+  +-------------------+  +-----------------------+  |
| [Dheer Jain]      |                                                                                                  |
| Supervisor        |  QUICK ACTIONS (GLOVED COMPLIANT)                                                                |
| Authenticated     |  +--------------------------------------------------------------------------------------------+  |
|                   |  | [ + REPORT BREAKDOWN INCIDENT ]                [ VIEW PRODUCTION LINES & CELLS ]           |  |
| [Log Out]         |  | [ CONDUCT SHIFT INSPECTION AUDIT ]             [ OPEN EQUIPMENT INVENTORY ]                |  |
|                   |  +--------------------------------------------------------------------------------------------+  |
+-------------------+--------------------------------------------------------------------------------------------------+
```

---

### 3.2 Screen 2: Production Lines & Work Cells Overview (`AllProductionLinesScreen`)

```
+----------------------------------------------------------------------------------------------------------------------+
| <- Production Lines & Work Cells                                                                                     |
| Real-time line capacity, active work cells, and operational throughput across production hubs.                       |
+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |
|   +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+         |
|   | TOTAL LINES           |  | RUNNING LINES         |  | MAINTENANCE / DEGRADED|  | BREAKDOWN STOPPAGES   |         |
|   |          4            |  |          2            |  |           1           |  |           1           |         |
|   | [=] All Hubs Active   |  | [*] Full Capacity     |  | [!] Verification Lock |  | [X] Line Halted       |         |
|   +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+         |
|                                                                                                                      |
|   [ Q Search production line or work cell name...                                                ] [RESET FILTERS]    |
|                                                                                                                      |
|   ACTIVE PRODUCTION HUBS (4)                                                                                         |
|                                                                                                                      |
|   +---------------------------------------------------------------------------------------------------------------+  |
|   | [ROUTE] Assembly Line 1                                               (o) RUNNING  (Pulsing Green)            |  |
|   |         12 Registered Machinery Units · 100% Operational Throughput                           [ DRILL DOWN ->]|  |
|   +---------------------------------------------------------------------------------------------------------------+  |
|                                                                                                                      |
|   +---------------------------------------------------------------------------------------------------------------+  |
|   | [ROUTE] Stamping & Press Cell B                                       (o) BREAKDOWN (Pulsing Red)             |  |
|   |         8 Registered Machinery Units · 1 Critical Stoppage (Hydraulic Press 02)              [ DRILL DOWN ->]|  |
|   +---------------------------------------------------------------------------------------------------------------+  |
|                                                                                                                      |
|   +---------------------------------------------------------------------------------------------------------------+  |
|   | [ROUTE] CNC Fabrication Cell 1                                        (!) MAINTENANCE (Amber)                 |  |
|   |         14 Registered Machinery Units · 1 Unit Pending Supervisor Signoff                     [ DRILL DOWN ->]|  |
|   +---------------------------------------------------------------------------------------------------------------+  |
|                                                                                                                      |
|   +---------------------------------------------------------------------------------------------------------------+  |
|   | [ROUTE] Packaging & Dispatch Line                                     (o) RUNNING  (Pulsing Green)            |  |
|   |         14 Registered Machinery Units · 100% Operational Throughput                           [ DRILL DOWN ->]|  |
|   +---------------------------------------------------------------------------------------------------------------+  |
|                                                                                                                      |
+----------------------------------------------------------------------------------------------------------------------+
```

---

### 3.3 Screen 3: Machine Details & Dual-Verification Dialog (`MachineDetailsScreen`)

```
+----------------------------------------------------------------------------------------------------------------------+
| <- CNC Milling Center 04 (CNC-MILL-04)                                                       [ RUNNING (Pulsing) ]   |
| Production Line: CNC Fabrication Cell 1 · Asset Tag: #8849-FL                                                        |
+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |
|   [ TAB: TELEMETRY & VITALS ]     [ TAB: SERVICE HISTORY ]     [ TAB: INSPECTION AUDITS ]                            |
|                                                                                                                      |
|   LIVE MACHINE TELEMETRY                                                                                             |
|   +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+         |
|   | SPINDLE SPEED         |  | MOTOR TEMPERATURE     |  | HYDRAULIC PRESSURE    |  | RUNTIME TODAY         |         |
|   |       12,400 RPM      |  |        54.2 °C        |  |        142 PSI        |  |      7.4 Hours        |         |
|   | Nominal Tolerance     |  | Normal Thermal Band   |  | Optimal Fluid Level   |  | 98.2% Availability    |         |
|   +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+         |
|                                                                                                                      |
|   MAINTENANCE ACTIONS                                                                                                |
|   +---------------------------------------------------------------------------------------------------------------+  |
|   | [ ! REPORT BREAKDOWN STOPPAGE ]                       [ CONDUCT SAFETY CHECKLIST AUDIT ]                      |  |
|   +---------------------------------------------------------------------------------------------------------------+  |
|                                                                                                                      |
|   RECENT MAINTENANCE AUDIT TRAIL                                                                                     |
|   - 2026-10-26 14:30: Repair approved by supervisor@plant.com (New ceramic bearings tested 100%)                     |
|   - 2026-10-26 14:15: Repair submitted by dheer.tech@plant.com (Pending Verification Lock)                           |
|   - 2026-10-26 11:20: Breakdown reported by operator.mohit@plant.com (Excessive spindle vibration)                  |
|                                                                                                                      |
+----------------------------------------------------------------------------------------------------------------------+
```

---

### 3.4 Screen 4: Supervisor Dual-Authorization Modal (`reviewRepair`)

```
+-----------------------------------------------------------------------------------------------+
|                       SUPERVISOR WORK ORDER SIGN-OFF & SAFETY VERIFICATION                    |
+-----------------------------------------------------------------------------------------------+
|                                                                                               |
|   Machine:       5-Axis CNC Milling Center (CNC-MILL-04)                                      |
|   Location:      CNC Fabrication Cell 1                                                       |
|   Technician:    Dheer Jain (dheer.tech@manufactureos.local)                                  |
|   Submitted At:  2026-10-26 14:15:00 IST                                                      |
|                                                                                               |
|   TECHNICIAN REPAIR NOTES:                                                                    |
|   +---------------------------------------------------------------------------------------+   |
|   | "Replaced worn spindle bearings with OEM SKF-6204 ceramic bearings. Aligned shaft to  |   |
|   | 0.002mm tolerance. Completed 15-minute dry-run without thermal anomalies."           |   |
|   +---------------------------------------------------------------------------------------+   |
|                                                                                               |
|   SUPERVISOR SAFETY REVIEW NOTES (MANDATORY IF REJECTED):                                     |
|   +---------------------------------------------------------------------------------------+   |
|   | Electrical lock-out removed. Vibration analyzer reads within normal limits.           |   |
|   +---------------------------------------------------------------------------------------+   |
|                                                                                               |
|   SAFETY WARNING: Approving will instantly energize equipment and set status to RUNNING.      |
|                                                                                               |
|   [ X REJECT & MAINTAIN STOPPAGE ]                 [ V APPROVE & RE-ENERGIZE EQUIPMENT ]      |
|   (Returns status to Breakdown)                    (Sets status to Running, updates Line)     |
|                                                                                               |
+-----------------------------------------------------------------------------------------------+
```

---

## 4. End-to-End User Interaction Flows

### 4.1 Flow A: Urgent Breakdown Incident Reporting
```mermaid
flowchart TD
    Start([Machine Anomaly Detected]) --> Step1[Operator taps 'Report Breakdown']
    Step1 --> Step2[Select Machine ID & Line]
    Step2 --> Step3[Choose Severity: Critical / High / Med / Low]
    Step3 --> Step4[Type Stoppage Notes]
    Step4 --> Step5{Confirm Submission?}
    Step5 -- No --> Abort([Cancel & Dismiss])
    Step5 -- Yes --> Step6[Firestore Writes /breakdowns and sets machine.status = Breakdown]
    Step6 --> Step7[Line Health Aggregator immediately shifts Line Status to Breakdown]
    Step7 --> Step8[Pulsing Crimson Badge appears on all plant screens]
    Step8 --> End([Technician Alerted])
```

### 4.2 Flow B: Dual-Authorization Work Order Sign-off
```mermaid
flowchart TD
    TechStart([Technician Finishes Physical Repair]) --> Form[Open 'Submit Repair Work Order']
    Form --> FormInput[Input Detailed Component Notes & Torque Checks]
    FormInput --> SubmitTech[Invoke Cloud Function: reportRepair]
    SubmitTech --> Assert1{Machine in Breakdown?}
    Assert1 -- No --> Error1[Throw failed-precondition: Abort]
    Assert1 -- Yes --> SetPending[Atomically update status = 'Pending Verification']
    SetPending --> Lock[Machine Locked Out; Cannot Run]
    
    Lock --> AdminNotice([Supervisor Notified for Inspection])
    AdminNotice --> AdminPhysical[Supervisor Physical Safety Check on Floor]
    AdminPhysical --> AdminReview[Open Review Modal]
    AdminReview --> Decision{Approve or Reject?}
    
    Decision -- Reject --> FuncReject[Invoke reviewRepair: reject + notes]
    FuncReject --> RevertBreakdown[Machine reverts to Breakdown; Tech re-assigned]
    
    Decision -- Approve --> FuncApprove[Invoke reviewRepair: approve]
    FuncApprove --> UnlockRunning[Machine unlocked; status = Running]
    UnlockRunning --> HistoryLog[Write immutable /workHistory ledger]
    HistoryLog --> Done([Full Line Throughput Restored])
```

---

## 5. Accessibility, Factory Ergonomics & Compliance Checklist

- [x] **Color Blindness Accessibility (Protanopia / Deuteranopia / Tritanopia):** Status is never communicated by color alone. Every status badge combines an unambiguous icon (`Icons.check_circle_rounded` vs `Icons.warning_amber_rounded` vs `Icons.cancel_rounded`), clear uppercase text, and a distinct pulsing aura.
- [x] **Screen Contrast Ratios:** Exceeds WCAG AAA guidelines across all primary interaction elements (14.8:1 contrast on carbon primary buttons).
- [x] **Single-Handed Handheld Operation:** On mobile form factors, primary tabs and actions sit in the lower 40% thumb zone of the display.
- [x] **Screen-Reader Compatibility:** Semantics nodes explicitly identify line names, machine counts, and operational percentages for assistive floor devices.
