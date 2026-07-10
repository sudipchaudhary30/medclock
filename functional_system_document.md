# MedClock Functional System Document

## 1. Purpose of the Application
MedClock is a medication management application designed for two user roles:
- Patient: manages personal medication schedules, dose logging, adherence tracking, and refill requests.
- Caregiver: monitors a linked patient’s medication habits and receives visibility into missed or taken doses.

The app aims to improve medication adherence by combining reminders, dose confirmation, supply tracking, and caregiver visibility in one system.

---

## 2. System Overview

### 2.1 Frontend
- Flutter + Dart
- Riverpod for state management
- Local storage via Hive for offline-friendly behavior
- Material UI with custom screens for patient and caregiver experiences

### 2.2 Backend
- Node.js + Express
- MongoDB database
- REST API endpoints for authentication, medications, reminders, dose logs, and family/caregiver relationships

### 2.3 Main Architectural Idea
The app is organized around two user experiences:
- Patient flow: home dashboard, reminders, medication list, dose history, refill management, profile/settings.
- Caregiver flow: caregiver dashboard, patient monitoring, sync/share invitation flow.

---

## 3. Core User Roles

### 3.1 Patient Side
The patient experience is centered around daily medication compliance.

Main capabilities:
- Register/login and maintain account
- Add medications with name, dosage, supply count, and schedule
- Receive reminder schedule for each medication
- Confirm doses as taken
- Log missed doses with a reason
- View medication history and adherence statistics
- Check refill status and request refills
- Share access with a caregiver through QR-link or invitation flow

### 3.2 Caregiver Side
The caregiver experience is centered around monitoring the patient remotely.

Main capabilities:
- Sign up as caregiver
- Link to a patient using a QR/invitation-based sharing flow
- View a dashboard with linked patients
- See compliance status and alert conditions
- Monitor missed or confirmed doses
- Support the patient’s adherence process

---

## 4. Patient Functional Flow

### 4.1 Authentication and App Entry
The app starts by checking whether the user is already authenticated.
- If no session exists, the user is sent to onboarding or login.
- If the user is a caregiver, the app routes to the caregiver dashboard.
- If the user is a patient, the app routes to the home screen.

Relevant files:
- [lib/app.dart](lib/app.dart)
- [lib/screens/onboarding/splash_screen.dart](lib/screens/onboarding/splash_screen.dart)
- [lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart)

### 4.2 Home Dashboard
The home screen acts as the patient’s main control center.

What it shows:
- Greeting with patient name
- Adherence streak and adherence rate summary
- Upcoming reminders for today
- Supply status cards for medications
- Quick navigation to reminders, dose history, medications, and profile

How it works:
- Reads from reminder, medication, and dose-log providers
- Calculates streak and adherence based on logged doses
- Displays the next reminder items and medication supply state

### 4.3 Medication Management
Patient can add medications from the add medication form.

Data captured:
- Medication name
- Supply count
- Reminder time
- Repeat days
- Photo of medication (optional)

How it works:
- The form builds a MedicationModel object
- The medication provider sends it to the backend
- The medication is stored and reflected in the medication list and reminders UI

### 4.4 Reminder and Scheduling Flow
Reminder schedules are tied to medications.

How it works:
- A medication can be assigned a scheduled time and repeat days
- Reminders are shown in the reminder list and on the home dashboard
- The patient can open a reminder and confirm a dose

### 4.5 Dose Logging Flow
The dose history screen is the core interaction for dose confirmation.

Available actions:
- Confirm a dose as taken
- Mark a dose as missed and enter a reason
- View status for each scheduled medication on a selected day

What happens when a dose is confirmed:
- A dose log is created with status “taken”
- The log is displayed in history and updates the adherence statistics

What happens when a dose is missed:
- A reason can be entered
- A missed dose log is recorded
- The UI reflects the missed state and allows the user to explain the issue

### 4.6 Refill Flow
The refill screen helps users manage supply health.

How it works:
- Shows medications that are below threshold or nearly empty
- Displays whether the medication is in stock, low stock, or needs refill
- Lets the user request a refill from a linked pharmacy

### 4.7 Caregiver Sharing Flow
Patients can generate a QR code or invitation link to share access with a caregiver.

How it works:
- The patient sees a QR code containing invitation data
- The caregiver can scan or use the link to begin sync
- Permissions can be toggled for medication access and refill alerts

---

## 5. Caregiver Functional Flow

### 5.1 Caregiver Dashboard
The caregiver dashboard serves as the main monitoring screen.

What it shows:
- Linked patient status
- Patient adherence percentage
- Alert/issue indicators
- Recent history of confirmations and misses

Current behavior:
- The dashboard uses example patient data when no linked group is present
- It offers a “No Patients Linked” state until connection is established

### 5.2 Linking Patients
Caregivers are expected to sync with a patient through a QR scan or invitation.

Current implementation status:
- The app contains a QR code sharing screen and scanner screen
- The UI supports the workflow conceptually
- The backend and provider layer appear to be partially implemented rather than fully wired end-to-end

### 5.3 Caregiver Monitoring Responsibilities
Once connected, the caregiver can:
- Inspect the patient’s medication schedule and adherence trends
- See when doses are missed or confirmed
- Support the patient by monitoring refill needs and compliance state

---

## 6. Data Model Summary

### 6.1 User Model
Represents either a patient or caregiver account.
- Includes name, email, role, phone
- Stores settings and profile preferences
- Identifies access role for routing and screen behavior

### 6.2 Medication Model
Represents a medication entry.
- Name
- Dosage
- Form
- Total supply and current supply
- Refill threshold
- Optional pill photo

### 6.3 Reminder Model
Represents a scheduled reminder.
- Medication ID
- Scheduled time
- Days of repetition
- Snooze state

### 6.4 Dose Log Model
Represents a historical dose entry.
- Medication ID
- Scheduled time
- Status: taken, missed, or pending
- Confirmation timestamp
- Optional note or reason for missed dose

### 6.5 Family Group Model
Represents the caregiver’s care circle.
- Group name
- Creator ID
- Member list

---

## 7. Backend API Responsibilities

### Authentication
- Register user
- Login user
- Update profile

### Medication APIs
- Fetch medications for the logged-in user
- Create a new medication

### Reminder APIs
- Fetch reminders
- Create reminders
- Snooze reminders

### Dose Log APIs
- Fetch dose logs
- Create new dose log
- Reduce current supply when a dose is marked taken

### Family APIs
- Fetch a family group
- Create family members for caregiver management

---

## 8. How The App Works in Practice

### 8.1 Patient Journey
1. User creates account and chooses patient role.
2. User adds medications and schedules reminders.
3. Home screen displays upcoming reminders and supply status.
4. User confirms doses from the dose-history view.
5. Missed doses can be logged with a reason.
6. Refill needs are surfaced when supply is low.
7. User can share caregiver access via QR link.

### 8.2 Caregiver Journey
1. Caregiver creates account.
2. Caregiver links to a patient via invitation or QR code.
3. Dashboard shows connected patient status.
4. Caregiver monitors completion and compliance.
5. Caregiver can help with refill awareness or missed dose follow-up.

---

## 9. Functional Risks and Areas to Review

### 9.1 Likely Functional Issues to Check
- Patient and caregiver roles may not be fully connected end-to-end
- QR sharing flow appears UI-driven but may not be fully integrated with backend sync
- Some screens use mock or placeholder data rather than real linked patient data
- The add medication flow may not fully create reminders automatically from selected days/time
- Dose logging and adherence calculations depend on data being present and correctly synced
- Family/caregiver relationship handling appears simpler than the UI suggests

### 9.2 What to Validate Manually
- Can a patient sign up, log in, add a medication, and confirm a dose successfully?
- Does the reminder appear on the home screen and reminder list?
- Does the dose history update after confirmation or missed logging?
- Does the refill screen respond correctly to low supply?
- Can a caregiver view a linked patient and see meaningful status?
- Does the QR sharing flow produce a usable invitation or sync link?

---

## 10. Suggested Testing Checklist

### Patient Side
- [ ] Register as patient
- [ ] Log in successfully
- [ ] Add medication
- [ ] View medication on home screen
- [ ] Confirm taken dose
- [ ] Log missed dose with reason
- [ ] View updated adherence stats
- [ ] Request refill
- [ ] Share caregiver link

### Caregiver Side
- [ ] Register as caregiver
- [ ] Link to a patient
- [ ] View caregiver dashboard
- [ ] See patient status and alert state
- [ ] Confirm that linked data appears correctly

---

## 11. Summary
MedClock is a dual-role medication adherence platform with a strong patient-first experience and a supporting caregiver monitoring layer. The app’s core value is clear: help patients stay on schedule while giving caregivers visibility and support. The most important areas to review are real data flow, role-based connectivity, and whether the caregiver link and monitoring experience are functioning beyond the mocked UI.
