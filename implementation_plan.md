# MedClock — Flutter + MongoDB Implementation Plan

## Overview

MedClock is a medication management app for **Patients** and **Caregivers** with pill identification, reminders, dose logging, caregiver notifications, family dashboards, refill management, smart scheduling, delivery tracking, and reports.

**Tech Stack**: Flutter 3.41 (Dart 3.11) · MongoDB (via REST API backend) · Node.js/Express backend · Firebase Cloud Messaging (push notifications)

> [!IMPORTANT]
> The user wants a **zip-ready project** with **reusable widgets** and a solid system architecture. UI polish will be done later.

---

## User Review Required

> [!WARNING]
> **Backend hosting**: The plan assumes a self-hosted Node.js/Express server with MongoDB Atlas. If you prefer a different backend (e.g., Firebase, Supabase, or a different MongoDB hosting), please let me know.

> [!IMPORTANT]
> **Scope for initial delivery**: Given the 50+ stories across 7 sprints, I will build the **full folder structure, models, services, screens, and reusable widgets for ALL sprints**, but will implement **Sprint 1–4 features fully** and provide **scaffold/placeholder screens for Sprints 5–7**. This gives you a working app you can iterate on. Confirm if this approach works or if you want all 7 sprints fully coded.

> [!IMPORTANT]
> **Authentication**: Plan uses email/password auth with JWT tokens stored securely. Should I also include Google/Apple sign-in?

---

## Open Questions

1. **MongoDB hosting** — MongoDB Atlas (cloud) or self-hosted? Plan assumes Atlas.
2. **Push notifications** — Firebase Cloud Messaging (FCM) for Android + iOS? Or a different service?
3. **Image storage** — Where to store pill photos and dose confirmation photos? Plan uses local storage + MongoDB GridFS / cloud storage (S3/Firebase Storage).
4. **Pharmacy API** — Sprint 5 mentions pharmacy integration. Is there a specific pharmacy API to integrate, or should I create a mock/placeholder?
5. **Calendar integration** — Sprint 6 mentions reading calendar events. Confirm Google Calendar API or device-native calendar.

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                Flutter App                   │
│  ┌─────────┐ ┌──────────┐ ┌──────────────┐  │
│  │ Screens │ │ Widgets  │ │  State Mgmt  │  │
│  │ (Pages) │ │(Reusable)│ │  (Provider)  │  │
│  └────┬────┘ └────┬─────┘ └──────┬───────┘  │
│       └───────────┼──────────────┘           │
│              ┌────┴─────┐                    │
│              │ Services │                    │
│              └────┬─────┘                    │
│              ┌────┴─────┐                    │
│              │API Client│                    │
│              └────┬─────┘                    │
└───────────────────┼──────────────────────────┘
                    │ HTTP/REST
┌───────────────────┼──────────────────────────┐
│           Node.js/Express Backend            │
│  ┌────────┐ ┌──────────┐ ┌───────────────┐   │
│  │ Routes │ │  Models  │ │  Middleware   │   │
│  │        │ │(Mongoose)│ │ (Auth/JWT)    │   │
│  └───┬────┘ └────┬─────┘ └──────┬────────┘   │
│      └───────────┼──────────────┘            │
│             ┌────┴─────┐                     │
│             │ MongoDB  │                     │
│             │  Atlas   │                     │
│             └──────────┘                     │
└──────────────────────────────────────────────┘
```

---

## Proposed Changes

### Flutter Project Structure

```
medclock/
├── lib/
│   ├── main.dart
│   ├── app.dart                          # MaterialApp, routes, theme
│   │
│   ├── config/
│   │   ├── app_constants.dart            # API URLs, timeouts, thresholds
│   │   ├── app_theme.dart                # ThemeData, colors, text styles
│   │   └── routes.dart                   # Named route definitions
│   │
│   ├── models/                           # Data models (Dart classes)
│   │   ├── user_model.dart               # Patient/Caregiver with role enum
│   │   ├── medication_model.dart         # Medication with pill photo, dosage
│   │   ├── reminder_model.dart           # Reminder with schedule, snooze
│   │   ├── dose_log_model.dart           # Dose log with photo, status, reason
│   │   ├── family_member_model.dart      # Linked family members
│   │   ├── notification_model.dart       # Caregiver notification preferences
│   │   ├── refill_model.dart             # Refill thresholds, orders
│   │   └── delivery_model.dart           # Delivery tracking
│   │
│   ├── services/                         # Business logic & API calls
│   │   ├── api_service.dart              # HTTP client wrapper (Dio)
│   │   ├── auth_service.dart             # Login, register, JWT management
│   │   ├── medication_service.dart       # CRUD medications
│   │   ├── reminder_service.dart         # Schedule, snooze, fire reminders
│   │   ├── dose_log_service.dart         # Log doses, photo upload
│   │   ├── notification_service.dart     # FCM, local notifications
│   │   ├── family_service.dart           # Family member management
│   │   ├── refill_service.dart           # Refill tracking, auto-order
│   │   ├── delivery_service.dart         # Delivery tracking
│   │   ├── local_storage_service.dart    # Hive/SharedPrefs for offline
│   │   ├── sync_service.dart             # Offline → online sync
│   │   └── camera_service.dart           # Camera for pill photos
│   │
│   ├── providers/                        # State management (Provider/Riverpod)
│   │   ├── auth_provider.dart
│   │   ├── medication_provider.dart
│   │   ├── reminder_provider.dart
│   │   ├── dose_log_provider.dart
│   │   ├── family_provider.dart
│   │   ├── refill_provider.dart
│   │   └── notification_provider.dart
│   │
│   ├── widgets/                          # ★ REUSABLE WIDGETS ★
│   │   ├── buttons/
│   │   │   ├── mc_primary_button.dart    # Primary action button
│   │   │   ├── mc_secondary_button.dart  # Secondary/outline button
│   │   │   ├── mc_icon_button.dart       # Icon-only button (48x48 min)
│   │   │   ├── mc_text_button.dart       # Flat text button
│   │   │   ├── mc_fab.dart               # Floating action button
│   │   │   └── mc_snooze_button.dart     # Snooze-specific button
│   │   │
│   │   ├── cards/
│   │   │   ├── mc_reminder_card.dart     # Pill photo + name + dose + actions
│   │   │   ├── mc_medication_card.dart   # Medication summary card
│   │   │   ├── mc_dose_log_card.dart     # Dose history entry card
│   │   │   ├── mc_family_member_card.dart# Family member summary
│   │   │   ├── mc_refill_card.dart       # Refill status card
│   │   │   └── mc_delivery_card.dart     # Delivery tracking card
│   │   │
│   │   ├── inputs/
│   │   │   ├── mc_text_field.dart        # Styled text input
│   │   │   ├── mc_dropdown.dart          # Styled dropdown
│   │   │   ├── mc_time_picker.dart       # Time picker wrapper
│   │   │   ├── mc_date_picker.dart       # Date picker wrapper
│   │   │   ├── mc_search_field.dart      # Search input with icon
│   │   │   └── mc_pin_input.dart         # Passcode input (for overrides)
│   │   │
│   │   ├── dialogs/
│   │   │   ├── mc_confirm_dialog.dart    # Confirmation dialog
│   │   │   ├── mc_alert_dialog.dart      # Warning/error dialog
│   │   │   ├── mc_loading_dialog.dart    # Loading overlay
│   │   │   └── mc_bottom_sheet.dart      # Reusable bottom sheet
│   │   │
│   │   ├── indicators/
│   │   │   ├── mc_streak_badge.dart      # Adherence streak indicator
│   │   │   ├── mc_supply_indicator.dart  # Dose supply countdown
│   │   │   ├── mc_adherence_chart.dart   # Weekly/monthly adherence chart
│   │   │   └── mc_progress_bar.dart      # Generic progress bar
│   │   │
│   │   ├── layout/
│   │   │   ├── mc_app_bar.dart           # Custom app bar
│   │   │   ├── mc_bottom_nav.dart        # Bottom navigation bar
│   │   │   ├── mc_scaffold.dart          # App scaffold with nav
│   │   │   ├── mc_section_header.dart    # Section title widget
│   │   │   └── mc_empty_state.dart       # Empty state placeholder
│   │   │
│   │   ├── media/
│   │   │   ├── mc_pill_image.dart        # Pill photo with fallback
│   │   │   ├── mc_camera_button.dart     # One-tap camera trigger
│   │   │   └── mc_photo_viewer.dart      # Full-screen photo view
│   │   │
│   │   └── common/
│   │       ├── mc_divider.dart           # Styled divider
│   │       ├── mc_badge.dart             # Status badge (taken/missed/pending)
│   │       ├── mc_chip.dart              # Filter/category chip
│   │       ├── mc_avatar.dart            # User/member avatar
│   │       ├── mc_similarity_warning.dart# Similar pill warning banner
│   │       └── mc_toast.dart             # Snackbar/toast helper
│   │
│   ├── screens/                          # App screens organized by feature
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart    # 5-step guided setup
│   │   │   ├── role_selection_screen.dart # Patient vs Caregiver
│   │   │   └── medication_setup_screen.dart
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart          # Today's schedule + supply counts
│   │   │
│   │   ├── reminders/
│   │   │   ├── reminder_screen.dart      # Active reminder (single med view)
│   │   │   ├── reminder_list_screen.dart # All upcoming reminders
│   │   │   └── snooze_screen.dart
│   │   │
│   │   ├── medications/
│   │   │   ├── medication_list_screen.dart
│   │   │   ├── medication_detail_screen.dart
│   │   │   ├── add_medication_screen.dart
│   │   │   └── pill_photo_screen.dart    # Capture/view pill photo
│   │   │
│   │   ├── dose_logging/
│   │   │   ├── dose_confirm_screen.dart  # One-tap confirm + camera
│   │   │   ├── dose_history_screen.dart  # 30-day history
│   │   │   └── missed_dose_screen.dart   # Log missed dose with reason
│   │   │
│   │   ├── caregiver/
│   │   │   ├── caregiver_dashboard.dart  # Real-time updates
│   │   │   ├── caregiver_settings_screen.dart # Quiet hours, alerts
│   │   │   └── daily_summary_screen.dart # Daily dose summary
│   │   │
│   │   ├── family/
│   │   │   ├── family_dashboard_screen.dart # All members, colour-coded
│   │   │   ├── add_member_screen.dart
│   │   │   └── member_detail_screen.dart
│   │   │
│   │   ├── refill/
│   │   │   ├── refill_screen.dart        # Refill status & thresholds
│   │   │   └── refill_settings_screen.dart
│   │   │
│   │   ├── delivery/
│   │   │   ├── delivery_tracking_screen.dart
│   │   │   └── pharmacy_map_screen.dart
│   │   │
│   │   ├── reports/
│   │   │   ├── reports_screen.dart       # Adherence charts
│   │   │   └── export_screen.dart        # PDF export
│   │   │
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       ├── notification_settings_screen.dart
│   │       ├── accessibility_settings_screen.dart
│   │       └── profile_screen.dart
│   │
│   └── utils/
│       ├── date_utils.dart               # Date/time formatting helpers
│       ├── validators.dart               # Form validation
│       ├── extensions.dart               # Dart extensions
│       └── helpers.dart                  # General utility functions
│
├── backend/                              # Node.js/Express + MongoDB
│   ├── package.json
│   ├── server.js
│   ├── config/
│   │   └── db.js                         # MongoDB connection
│   ├── middleware/
│   │   ├── auth.js                       # JWT verification
│   │   └── upload.js                     # Multer for photo uploads
│   ├── models/
│   │   ├── User.js
│   │   ├── Medication.js
│   │   ├── Reminder.js
│   │   ├── DoseLog.js
│   │   ├── FamilyGroup.js
│   │   ├── Notification.js
│   │   ├── Refill.js
│   │   └── Delivery.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── medications.js
│   │   ├── reminders.js
│   │   ├── doseLogs.js
│   │   ├── family.js
│   │   ├── notifications.js
│   │   ├── refills.js
│   │   └── delivery.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── medicationController.js
│   │   ├── reminderController.js
│   │   ├── doseLogController.js
│   │   ├── familyController.js
│   │   ├── notificationController.js
│   │   ├── refillController.js
│   │   └── deliveryController.js
│   └── utils/
│       ├── fcm.js                        # Firebase Cloud Messaging
│       └── helpers.js
│
├── pubspec.yaml
└── README.md
```

---

### MongoDB Schema Design

#### Users Collection
```javascript
{
  _id: ObjectId,
  email: String,
  passwordHash: String,
  name: String,
  role: "patient" | "caregiver",
  phone: String,
  fcmTokens: [String],           // Push notification tokens (multi-device)
  linkedUsers: [ObjectId],       // Caregiver ↔ Patient links
  familyGroupId: ObjectId,
  settings: {
    fontSize: Number,            // Default 16
    quietHoursStart: String,     // "23:00"
    quietHoursEnd: String,       // "07:00"
    reminderSound: String,
    reminderVolume: Number
  },
  createdAt: Date,
  updatedAt: Date
}
```

#### Medications Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  name: String,
  dosage: String,                // "500mg"
  form: String,                  // "tablet", "capsule", "inhaler", etc.
  pillPhotoUrl: String,
  color: String,                 // For similarity detection
  shape: String,                 // For similarity detection
  instructions: String,
  totalSupply: Number,           // Total pills added
  currentSupply: Number,         // Remaining count
  refillThreshold: Number,       // Default 7 days
  autoRefill: Boolean,
  pharmacyId: String,
  similarMedications: [ObjectId], // IDs of similar-looking meds
  isActive: Boolean,
  createdAt: Date
}
```

#### Reminders Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  medicationId: ObjectId,
  familyMemberId: ObjectId,      // If caregiver managing for someone
  scheduledTime: String,         // "08:00"
  days: [String],                // ["Mon","Tue",...]
  isRelativeToShift: Boolean,
  shiftOffset: Number,           // Minutes from shift start
  calendarAware: Boolean,
  maxSnoozeCount: Number,        // Default 2
  currentSnoozeCount: Number,
  status: "active" | "snoozed" | "fired" | "dismissed",
  isOfflineCapable: Boolean,     // Default true
  adaptiveEnabled: Boolean,
  lateCount: Number,             // For adaptive reminders
  createdAt: Date
}
```

#### DoseLogs Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  medicationId: ObjectId,
  reminderId: ObjectId,
  familyMemberId: ObjectId,
  status: "taken" | "missed" | "skipped",
  confirmedAt: Date,
  scheduledAt: Date,
  photoUrl: String,
  missedReason: "forgot" | "asleep" | "side_effect" | "other",
  missedNote: String,
  confirmedBy: ObjectId,         // Who confirmed (patient or caregiver)
  syncedToServer: Boolean,       // For offline tracking
  createdAt: Date
}
```

#### FamilyGroups Collection
```javascript
{
  _id: ObjectId,
  name: String,
  createdBy: ObjectId,
  members: [{
    userId: ObjectId,
    name: String,
    color: String,               // Colour-coded in dashboard
    role: "patient" | "caregiver",
    addedAt: Date
  }],
  createdAt: Date
}
```

#### Notifications Collection
```javascript
{
  _id: ObjectId,
  recipientId: ObjectId,
  type: "dose_confirmed" | "dose_missed" | "daily_summary" | "refill_alert" | "delivery_update",
  title: String,
  body: String,
  data: Object,                  // Payload
  photoUrl: String,
  isRead: Boolean,
  isQueued: Boolean,             // For quiet hours
  scheduledDeliveryAt: Date,
  sentAt: Date,
  createdAt: Date
}
```

#### Refills Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  medicationId: ObjectId,
  status: "pending" | "ordered" | "shipped" | "delivered",
  triggeredAt: Date,
  orderedAt: Date,
  pharmacyId: String,
  isAutoOrder: Boolean,
  isUrgent: Boolean,
  estimatedCost: Number,
  deliveryId: ObjectId,
  createdAt: Date
}
```

---

### Reusable Widgets (★ Key Deliverable)

All widgets follow these principles:
- **Minimum touch target**: 48×48 dp (accessibility requirement)
- **Minimum spacing**: 12 dp between interactive elements
- **Default font size**: 16pt minimum on key screens
- **Prefix**: All widgets prefixed `Mc` (MedClock) for easy discovery
- **Consistent API**: Named parameters, callbacks, theming support

| Widget | Used In | Key Props |
|--------|---------|-----------|
| `McPrimaryButton` | Every screen | label, onTap, isLoading, icon, size |
| `McSecondaryButton` | Dialogs, forms | label, onTap, outlined |
| `McIconButton` | Reminder actions | icon, onTap, size (min 48), badge |
| `McReminderCard` | Reminder, Home | medication, pillPhoto, dose, streakCount, onConfirm, onSnooze |
| `McMedicationCard` | Med list, Dashboard | medication, supplyCount, onTap |
| `McDoseLogCard` | History | doseLog, showPhoto |
| `McFamilyMemberCard` | Family dashboard | member, color, status |
| `McTextField` | All forms | label, hint, validator, obscure |
| `McDropdown` | Forms | items, selected, onChanged |
| `McPillImage` | Reminder, Med detail | imageUrl, size, fallbackIcon |
| `McCameraButton` | Dose confirm | onCapture, size |
| `McStreakBadge` | Reminder card | count, animated |
| `McSupplyIndicator` | Home, Med card | current, total, threshold |
| `McBadge` | Dose log, Dashboard | status (taken/missed/pending) |
| `McSimilarityWarning` | Reminder card | similarMeds[] |
| `McAppBar` | All screens | title, actions, backButton |
| `McBottomNav` | Main screens | selectedIndex, role |
| `McScaffold` | All screens | body, appBar, bottomNav, fab |
| `McConfirmDialog` | Dose confirm, Delete | title, message, onConfirm |
| `McLoadingDialog` | API calls | message, isVisible |
| `McEmptyState` | Lists | icon, title, subtitle, action |
| `McSectionHeader` | Dashboard, Home | title, actionLabel, onAction |
| `McPinInput` | Override passcode | length, onComplete |
| `McAdherenceChart` | Reports, Dashboard | data[], period |

---

### Sprint Implementation Scope

#### Sprint 1 — Foundation & Pill Identification ✅ (Fully implemented)
- Auth (login, register, JWT)
- Onboarding (5-step guided setup with role selection)
- Medication CRUD with pill photo capture
- Reminder card showing pill photo + name + dosage
- Similar pill warning system
- All backend routes for auth + medications

#### Sprint 2 — Reminders & Dose Logging ✅ (Fully implemented)
- Local notifications (flutter_local_notifications + workmanager for offline)
- Snooze (15 min, max 2 per dose)
- Single medication per reminder view
- Offline reminder firing + local storage + sync
- One-tap dose confirmation
- Camera-based dose logging
- Streak tracking on reminder cards

#### Sprint 3 — Safety & Caregiver Alerts ✅ (Fully implemented)
- Double-dose prevention (4-hour block with passcode override)
- Missed dose logging with reason dropdown
- Real-time caregiver notifications via FCM
- Daily summary generation
- Silent log updates for caregiver dashboard
- Instant missed dose alerts
- Quiet hours configuration
- Remote medication setup for caregivers

#### Sprint 4 — Family Dashboard ✅ (Fully implemented)
- Multi-member dashboard (colour-coded, swipeable)
- Per-device push notifications
- Member selection before dose confirmation
- Add member flow (3 steps)
- Large fonts + large buttons (accessibility)
- Photo storage per dose log (90-day retention)

#### Sprints 5–7 — Scaffolded (screens + models + routes, logic placeholders)
- Refill management screens & models
- Delivery tracking screens & models
- Smart scheduling screens
- Reports & export screens
- Pharmacy map screen (placeholder)

---

### Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0                    # HTTP client
  provider: ^6.1.1               # State management
  flutter_local_notifications: ^17.0.0
  workmanager: ^0.5.2            # Background tasks (offline reminders)
  hive: ^2.2.3                   # Local storage
  hive_flutter: ^1.1.0
  image_picker: ^1.0.7           # Camera
  cached_network_image: ^3.3.1   # Pill photos
  flutter_secure_storage: ^9.0.0 # JWT storage
  intl: ^0.19.0                  # Date formatting
  fl_chart: ^0.66.0              # Adherence charts
  pdf: ^3.10.8                   # PDF export
  path_provider: ^2.1.2
  permission_handler: ^11.3.0
  connectivity_plus: ^6.0.3      # Online/offline detection
  uuid: ^4.3.3
```

### Backend Dependencies (package.json)

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^8.0.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "multer": "^1.4.5-lts.1",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "firebase-admin": "^12.0.0",
    "node-cron": "^3.0.3"
  }
}
```

---

## Verification Plan

### Automated Tests
```bash
# Flutter
flutter analyze
flutter test

# Backend
npm test
```

### Manual Verification
- `flutter run` to verify app launches and navigates correctly
- Backend starts with `node server.js` and responds to API calls
- Test auth flow: register → login → get token → access protected routes
- Verify all reusable widgets render correctly in isolation
- Confirm offline reminder scheduling works

### Deliverable
- Complete project zipped and ready to download
- README.md with setup instructions
