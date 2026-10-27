# ManufactureOS: Industrial Telemetry & Incident Operations Platform

ManufactureOS is a mission-critical shop-floor telemetry, machine health monitoring, and dual-authorization incident operations system designed for industrial manufacturing plants.

---

## Production Architecture & Engineering Suite

Comprehensive Tier-1 production architecture documentation is available in the [`docs/`](./docs) directory:

- **[Product Requirements Document (PRD)](./docs/PRD.md):** Business objectives, user personas (Operator, Technician, Supervisor), functional epics, Gherkin acceptance criteria, OEE/MTTR metrics, and rollout roadmap.
- **[High-Level Design Document (HLD)](./docs/HLD.md):** Distributed system architecture, C4 models, deterministic machine finite state machine (FSM), Firestore ACID transaction isolation, and zero-trust security architecture.
- **[Low-Level Design Document (LLD)](./docs/LLD.md):** Component class design, complete data dictionary and schemas (`machines`, `breakdowns`, `repairRequests`, `workHistory`, `inspectionReports`), Cloud Functions v2 API contracts, and real-time aggregation algorithms.
- **[Mock UX & Ergonomics Specification (MOCK UX)](./docs/MOCK_UX.md):** Gloved industrial touch targets ($\ge 48\text{dp}$), high-contrast WCAG AAA color palette, adaptive multi-platform navigation shell, and ASCII wireframes.

---

## Core System Architecture

- **Client Presentation:** Flutter (Cross-platform support for Android ruggedized tablets, iOS handhelds, and Linux/macOS/Web supervisory terminals).
- **Backend & Cloud Compute:** Google Cloud Functions v2 (`asia-south1`) executing atomic ACID transactions.
- **Data Persistence:** Cloud Firestore distributed active-active multi-region cluster with offline SQLite caching.
- **Security & RBAC:** Google Cloud Identity with custom claims, strict Firestore Security Rules, and server-side dual-authorization safety locks.

---

## Getting Started

### Prerequisites
- Flutter SDK 3.13.4+
- Dart SDK 3.1.0+
- Firebase CLI & Active Project Configuration

### Installation & Launch
```bash
# Clone the repository
git clone https://github.com/kalviumcommunity/manufacturing_app.git
cd manufacturing_app

# Install client dependencies
flutter pub get

# Run test suite
flutter test

# Launch debug runner
flutter run
```
