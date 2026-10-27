# ManufactureOS Architectural Engineering Suite

Welcome to the production engineering and architectural documentation for **ManufactureOS**, an enterprise-grade industrial telemetry, equipment health, and dual-authorization incident operations platform.

This directory houses the complete engineering design suite developed in compliance with Tier-1 industrial tech standards (Google, Tesla, Rockwell Automation).

---

## Architecture Suite Navigation

| Document | Primary Focus | Key Contents | Target Audience |
| :--- | :--- | :--- | :--- |
| **[PRD (Product Requirements Document)](./PRD.md)** | **Product Strategy & Requirements** | Executive summary, industrial downtime problem space, target personas (Operators, Techs, Supervisors), functional epics (P0-P2), Gherkin acceptance criteria, OEE/MTTR/MTBF metrics, and release phasing. | Product Managers, Engineering Leads, Plant Directors |
| **[HLD (High-Level Design)](./HLD.md)** | **Distributed Systems Architecture** | C4 architectural diagrams (Context, Container, Component, Deployment), finite state machine (FSM), Firestore ACID transaction isolation, zero-trust RBAC model, network topology (`asia-south1`), and disaster recovery SLA. | Staff Engineers, Solutions Architects, Security Auditors |
| **[LLD (Low-Level Design)](./LLD.md)** | **Code Structure, Schemas & Algorithms** | Class diagrams, comprehensive data dictionary (`machines`, `breakdowns`, `repairRequests`, `workHistory`, `inspectionReports`, `users`), Cloud Functions API contracts, single-pass health aggregation, and sliding-window fault detection algorithms. | Software Engineers, QA Engineers, Core Contributors |
| **[MOCK UX (Design System & Wireframes)](./MOCK_UX.md)** | **Industrial Ergonomics & UI/UX** | Gloved operation touch targets ($\ge 48\text{dp}$), high-glare WCAG AAA color tokens, multi-platform adaptive navigation shell, ASCII wireframe diagrams, and interactive end-to-end user journeys. | UI/UX Designers, Frontend Developers, Ergonomics Reviewers |

---

## Architectural Principles Quick Reference

1. **Boring Technology First:** Flutter + Cloud Firestore + Google Cloud Functions v2. Proven, horizontal scalability with minimal moving parts.
2. **Stateless Clients, Centralized Truth:** Client devices are reactive projection screens. State resides in transactional cloud storage backed by local SQLite persistence.
3. **Fail-Closed Security:** Equipment safety locks are enforced server-side via atomic transactions. Machines cannot be restarted without cryptographic verification by an authenticated administrator.
4. **Loud Failures:** No swallowed errors. All validation failures throw typed exceptions (`HttpsError`) logged to Google Cloud Logging.
5. **Code for Deletion:** Isolated domain collections with clean boundaries enable modular refactoring without cascading system risk.
