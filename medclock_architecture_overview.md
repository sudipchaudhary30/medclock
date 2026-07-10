# MedClock System Architecture & Product Description

## 1. Product Description

**MedClock** is a comprehensive, dual-role medication management and health tracking application designed to bridge the gap between patients and their caregivers or family members. 

The application provides two distinct user experiences tailored to specific needs:
* **Patient Mode:** Empowers patients to manage their health independently. Patients can set up medication schedules, log doses, track adherence streaks, receive smart reminders, and request refills directly from linked pharmacies. 
* **Caregiver Mode:** Allows family members or healthcare providers to securely monitor a patient's progress. Caregivers link to patients via a secure QR code scan or a time-sensitive 6-digit sync code. Once connected, caregivers can view medication history, monitor adherence rates, receive alerts for missed doses, and configure adaptive reminders to assist the patient remotely.

**Core Value Proposition:** Enhancing medication adherence and patient safety through seamless family involvement, intuitive tracking interfaces, and robust offline-capable synchronization.

---

## 2. System Architecture

The application follows a modern, reactive, and modular architecture built primarily on the Flutter framework.

### 2.1 Technology Stack
* **Frontend Framework:** Flutter (Dart) for cross-platform deployment (Android, iOS).
* **State Management:** Riverpod (Notifier and Provider patterns) for reactive UI updates and dependency injection.
* **Local Storage & Offline Mode:** Hive / SharedPreferences (via a custom `LocalStorageService`) for local caching, allowing the app to function offline and synchronize when connectivity is restored.
* **Hardware Integration:** `mobile_scanner` for native camera QR code reading.
* **Notifications:** Firebase Cloud Messaging (FCM) integration (implied by `fcmTokens` in the user model) for remote push alerts.

### 2.2 Core Architectural Patterns

#### A. Dual-Shell Navigation Architecture
The app uses a sophisticated navigation shell pattern to isolate the Patient and Caregiver experiences while sharing common utility screens (like Profile and Settings).
* **`AppShell` (Patient):** Manages the bottom navigation state for patients (Home, Reminders, Medications, Profile).
* **`CaregiverAppShell`:** Manages the bottom navigation state for caregivers (Dashboard, History, Refills, Settings).
* Both shells utilize an `IndexedStack` with independent `GlobalKey<NavigatorState>` arrays to preserve the scrolling and navigation state of each tab independently.

#### B. Provider-Driven Data Flow (Riverpod)
Business logic and state are entirely decoupled from the UI layer using Riverpod:
* **`authProvider`**: Manages session state, user roles, and profile settings.
* **`medicationProvider`**: Manages the patient's active prescriptions and refill thresholds.
* **`doseLogProvider`**: Handles the logic for logging taken/missed doses and calculating adherence trends.
* **`familyProvider` & `syncCodeProvider`**: Manages the linking mechanism (generating 24-hour codes on the patient side and validating them on the caregiver side).
* **`SyncService`**: A dedicated service handling background synchronization between local storage and the backend REST API.

#### C. Modular UI Design System
The UI relies heavily on a centralized design system defined in `AppTheme`. This ensures consistency across both user roles:
* Standardized `McScaffold` for uniform screen structures.
* Centralized color tokens (`primaryColor`, `secondaryColor`, semantic colors like `takenColor` or `missedColor`).
* Adaptive components (e.g., `Switch.adaptive`) to ensure native feel on both iOS and Android.

### 2.3 Data Models
* **`UserModel`**: Contains authentication details, role (`patient` vs `caregiver`), linked user IDs, FCM tokens, and nested `UserSettings`.
* **`MedicationModel`**: Tracks drug names, dosages, forms, supply counts, and refill thresholds.
* **`DoseLogModel`**: Immutable records of historical doses (status: taken, missed, skipped, scheduled time, and confirmation timestamps).

### 2.4 Security & Privacy
* **Secure Linking:** Connection between a caregiver and a patient requires explicit opt-in via a physical QR scan or a short-lived, randomly generated 6-digit sync code.
* **Role-Based Access Control (RBAC):** Navigation routes and data access are strictly filtered based on the `UserRole` enumerated in the `UserModel`.
