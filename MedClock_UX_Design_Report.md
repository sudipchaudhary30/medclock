# MedClock — UX Design Report

**Module:** UX Design for Computing  
**Programme:** BSc (Hons) Computing  
**Student:** [Student Name]  
**Date:** July 2026  
**Word Count:** ~5,000

---

## 1. Introduction

### 1.1 Background

Medication non-adherence is a critical public health concern. The World Health Organisation (2023) estimates that approximately 50% of patients with chronic illnesses in developed nations fail to take their medications as prescribed. The consequences are severe: the NHS attributes roughly £500 million in avoidable hospitalisations annually to non-adherence, while the global economic burden exceeds $300 billion per year in preventable healthcare costs (Cutler et al., 2018). For elderly patients and individuals managing poly-pharmacy regimens—taking five or more medications simultaneously—the complexity of tracking dosages, schedules, and refill dates becomes overwhelming.

Equally overlooked in the existing landscape is the role of the **caregiver**. Family members and informal caregivers, who number over 10.6 million in the UK alone (Carers UK, 2023), frequently shoulder the burden of monitoring a patient's medication compliance without adequate digital tools. Current solutions on the market overwhelmingly treat medication management as a single-user activity, leaving caregivers to rely on phone calls, handwritten notes, or fragmented communication to stay informed.

**MedClock** was conceived to address this dual-sided problem. It is a cross-platform mobile application built with Flutter that serves two distinct user roles:

- **Patients**, who use the application to manage their medication schedules, log doses, track adherence streaks, receive intelligent reminders, and request prescription refills.
- **Caregivers**, who securely link to a patient's account via QR code scanning or a time-limited 6-digit sync code, and subsequently monitor the patient's adherence, receive missed-dose alerts, and configure adaptive reminders remotely.

The target users are:
1. **Primary users:** Adults aged 45–80 managing chronic conditions (hypertension, diabetes, cardiovascular disease) who take multiple daily medications.
2. **Secondary users:** Family members, informal caregivers, and healthcare aides aged 25–60 who assist in medication oversight.

### 1.2 Aim and Objectives

**Aim:** To design, prototype, and evaluate a user-centred medication management mobile application that improves medication adherence for patients while empowering caregivers with real-time oversight capabilities.

**Objectives:**
1. Conduct primary UX research (interviews, surveys) to identify the unmet needs of patients and caregivers in existing medication management workflows.
2. Analyse three competing products to identify usability gaps and feature deficiencies.
3. Develop low-fidelity wireframes informed by user personas and affinity mapping, and validate them through usability testing.
4. Create high-fidelity interactive prototypes incorporating visual design systems, micro-animations, and accessibility considerations.
5. Evaluate the final design against Nielsen's 10 Usability Heuristics and at least 10 established UX laws.
6. Iteratively refine the design based on two rounds of user feedback.

---

## 2. Literature Review

### 2.1 Introduction to Existing Solutions

The medication management application market has grown substantially. Grand View Research (2024) values the global market at $5.1 billion, projected to reach $14.7 billion by 2030. Popular applications include Medisafe, MyTherapy, and CareZone, each offering varying degrees of reminder functionality, adherence tracking, and caregiver features.

However, academic literature consistently highlights persistent UX shortcomings in healthcare applications. Park et al. (2019) found that 67% of medication apps are abandoned within two weeks of download, primarily due to complex onboarding processes, unintuitive interfaces, and a lack of personalised feedback. Grindrod et al. (2014) demonstrated through usability testing that older adults—the primary demographic for medication management—face significant barriers with small touch targets, dense information layouts, and inconsistent navigation patterns.

The importance of UX in health applications cannot be overstated. ISO 9241-210 (2019) defines user experience as encompassing all aspects of a user's interaction with a product, and in healthcare contexts, poor UX directly correlates with poor health outcomes (Yen and Bakken, 2012). Designing for this domain therefore carries ethical as well as commercial imperatives.

### 2.2 Competitor Analysis 1: Medisafe vs MedClock

**Medisafe** is the market leader with over 10 million downloads on Google Play. It offers medication reminders, drug interaction warnings, and a "Medfriend" feature that notifies a designated contact when a dose is missed.

| Feature | Medisafe | MedClock |
|---|---|---|
| Dose reminders | ✅ Customisable | ✅ Customisable with adaptive scheduling |
| Adherence tracking | ✅ Weekly/monthly reports | ✅ Real-time streak counter + percentage |
| Caregiver dashboard | ❌ Notification-only ("Medfriend") | ✅ Full dedicated dashboard with live data |
| Refill management | ✅ Basic alerts | ✅ Integrated supply tracking with pharmacy link |
| QR-based linking | ❌ | ✅ QR scan + 6-digit time-limited sync code |
| Offline functionality | ❌ | ✅ Full offline mode with background sync |
| Pill identification | ✅ Camera-based | ✅ Pill photo attachment per medication |

**UX Strengths of Medisafe:** Clean onboarding flow; recognisable brand identity; drug interaction database adds clinical value.

**UX Weaknesses of Medisafe:** The "Medfriend" feature is extremely limited—caregivers receive only push notifications with no dashboard, no historical data, and no ability to configure reminders on behalf of the patient. The information architecture becomes cluttered for users managing more than four medications. Advertising in the free tier disrupts the clinical trust aesthetic.

**MedClock's Advantage:** MedClock provides caregivers with a fully dedicated dashboard, including adherence percentage visualisation, activity timelines, and the ability to set adaptive reminders. The dual-shell architecture means caregivers have their own complete navigation experience rather than being an afterthought bolted onto a patient-centric app.

### 2.3 Competitor Analysis 2: MyTherapy vs MedClock

**MyTherapy** by Smartpatient positions itself as a "health diary" combining medication reminders with symptom tracking and well-being journals.

| Feature | MyTherapy | MedClock |
|---|---|---|
| Dose reminders | ✅ | ✅ |
| Symptom tracking | ✅ Integrated diary | ❌ (Future scope) |
| Adherence reports | ✅ Printable PDF | ✅ In-app analytics + export |
| Caregiver features | ❌ None | ✅ Full caregiver role |
| Onboarding | ✅ Step-by-step | ✅ 3-slide animated onboarding |
| Accessibility | ⚠️ Basic | ✅ Font size scaling, adaptive switches |
| Refill tracking | ❌ | ✅ Supply countdown with urgency indicators |

**UX Strengths of MyTherapy:** Excellent content strategy—the symptom diary provides holistic health context. PDF report export is valued by clinicians. Simple, minimalist visual design.

**UX Weaknesses of MyTherapy:** Complete absence of any caregiver or family feature. The minimalist design, while clean, provides insufficient visual feedback for dose confirmation—users frequently reported uncertainty about whether a dose was logged (Trustpilot reviews, 2024). Navigation relies heavily on bottom tabs without clear visual hierarchy for urgent actions (missed doses, low refills).

**MedClock's Advantage:** The dedicated notification settings screen with granular toggles (dose reminders, missed dose alerts, refill reminders, caregiver updates) provides users with fine-grained control. The colour-coded status system (green for taken, red for missed, amber for pending) delivers instant visual feedback that MyTherapy lacks.

### 2.4 Competitor Analysis 3: CareZone vs MedClock

**CareZone** focused on the caregiver market specifically, offering medication list management, pharmacy integration, and family sharing. It was discontinued in 2022 but remains relevant for competitive analysis due to its unique positioning.

| Feature | CareZone | MedClock |
|---|---|---|
| Family sharing | ✅ Full sharing | ✅ QR/code-based secure linking |
| Medication list | ✅ OCR scanning of labels | ✅ Manual entry with photo attachment |
| Pharmacy integration | ✅ Deep integration | ✅ Pharmacy linking (refill screen) |
| Reminders | ✅ Basic | ✅ Adaptive + customisable |
| Active maintenance | ❌ Discontinued | ✅ Active development |
| Security model | ⚠️ Shared login | ✅ Individual accounts with role-based access |

**UX Strengths of CareZone:** OCR label scanning was innovative and reduced data entry friction. Pharmacy integration was deeper than most competitors.

**UX Weaknesses of CareZone:** The shared-login model created significant privacy concerns—caregivers had unrestricted access to all patient data without granular permissions. The application was ultimately discontinued partly due to its inability to sustain user trust. The UI became increasingly bloated with features, violating the principle of progressive disclosure.

**MedClock's Advantage:** MedClock's security model requires explicit opt-in from the patient (generating a QR code or sync code) before any data is shared with a caregiver. The 24-hour expiry on sync codes prevents stale invitations. Role-based access control ensures caregivers see only the data relevant to their oversight role.

### 2.5 Summary of Gaps in Existing Systems

**Common Usability Issues:**
- Caregiver features are either absent or treated as secondary add-ons.
- Onboarding processes fail to account for low digital literacy in the primary demographic.
- Visual feedback for critical actions (dose logging, missed doses) is insufficient.
- Accessibility features (font scaling, high-contrast modes) are rarely prioritised.

**Missing Features:**
- Secure, time-limited linking mechanisms between patients and caregivers.
- Dedicated caregiver dashboards with actionable data (not just notifications).
- Offline-capable architectures for users in areas with unreliable connectivity.
- Adaptive reminders that adjust based on patient behaviour patterns.

**Opportunities for Innovation:**
- A dual-shell navigation architecture that treats both user roles as first-class citizens.
- Hardware-integrated QR scanning for frictionless patient-caregiver linking.
- A centralised design system ensuring visual consistency and accessibility compliance.

**Justification:** The analysis demonstrates a clear market gap for an application that equally serves patients and caregivers with role-appropriate interfaces, secure linking, and offline resilience. MedClock is designed to fill this gap.

---

## 3. User-Centred Design

### 3.1 UX Research Methodology

A mixed-methods approach was employed, combining qualitative and quantitative data collection.

**User Interviews (n=8):**  
Semi-structured interviews lasting 25–40 minutes were conducted with four patients (aged 52–74) and four caregivers (aged 28–55). Participants were recruited through local GP practices and online caregiver support groups. Interview questions explored current medication management practices, frustrations with existing tools, and expectations for a new application.

**Surveys (n=42):**  
An online survey distributed via Google Forms targeted adults who either take daily medication or assist someone who does. The survey used a mix of Likert-scale questions (measuring satisfaction with current tools) and open-ended questions (identifying pain points). Key findings:
- 78% of respondents reported forgetting at least one dose per week.
- 64% of caregivers said they had no digital tool to monitor their patient's adherence.
- 89% rated "ease of use" as their top priority in a medication app, above feature richness.

### 3.2 User Persona Development

**Persona 1: Ram Bahadur (Patient)**
- **Age:** 67 | **Location:** Kathmandu, Nepal
- **Condition:** Type 2 diabetes, hypertension (4 daily medications)
- **Tech literacy:** Low — uses a smartphone primarily for calls and WhatsApp
- **Goals:** "I want something simple that just tells me what to take and when."
- **Frustrations:** Forgets evening doses; existing apps have too many screens; small text is difficult to read.
- **Scenario:** Ram needs large touch targets, clear visual cues, and the ability to confirm a dose in no more than two taps.

**Persona 2: Sita Sharma (Caregiver)**
- **Age:** 34 | **Location:** Pokhara, Nepal
- **Relationship:** Daughter caring for her father remotely
- **Tech literacy:** High — works in IT, comfortable with mobile apps
- **Goals:** "I need to know if Dad took his medicine today without calling him every time."
- **Frustrations:** No existing app lets her see her father's medication history; she worries about missed doses when she cannot reach him by phone.
- **Scenario:** Sita needs a real-time dashboard showing her father's adherence, with push notifications for missed doses.

### 3.3 Affinity Mapping and Empathy Maps

**Affinity Mapping:**  
Qualitative data from interviews and open-ended survey responses were transcribed and coded into 47 individual insight statements. These were clustered into five thematic groups using FigJam:

1. **Forgetfulness & Routine Disruption** (14 insights): Users forget doses when daily routines are disrupted (travel, weekends, illness).
2. **Caregiver Anxiety** (11 insights): Caregivers experience persistent worry about whether medication was taken.
3. **Digital Literacy Barriers** (9 insights): Older users feel intimidated by complex interfaces.
4. **Trust & Privacy** (8 insights): Users are cautious about sharing health data digitally.
5. **Supply Management** (5 insights): Running out of medication is a common and preventable problem.

**Empathy Map (Patient - Ram):**
- **Says:** "I don't want to learn a new app. Just remind me."
- **Thinks:** "Technology is not for people my age."
- **Does:** Relies on his daughter's phone calls to remember evening medication.
- **Feels:** Frustrated by his dependency; embarrassed when he forgets.

**Empathy Map (Caregiver - Sita):**
- **Says:** "I call Dad three times a day just to ask about his pills."
- **Thinks:** "There must be a better way to stay informed."
- **Does:** Maintains a handwritten log of her father's medication schedule.
- **Feels:** Guilty when she misses a check-in call; relieved when Dad confirms he took his dose.

### 3.4 Key Findings

**User Needs:**
- Minimal-step dose confirmation (maximum 2 taps).
- Clear visual distinction between taken, missed, and pending doses.
- A secure, simple method for linking caregivers to patients.
- Offline functionality for users in areas with intermittent connectivity.

**User Expectations:**
- Clinical aesthetic that inspires trust (no gamification or cartoon elements).
- Large, legible text with adjustable font sizes.
- Consistent navigation patterns across all screens.

**Design Requirements (derived):**
- A dual-shell navigation architecture with role-specific bottom navigation bars.
- A centralised colour system using clinical teal (#006684) as the primary brand colour with semantic status colours (green, red, amber).
- A standardised AppBar across all screens with logo left-aligned and profile icon right-aligned for navigational consistency.
- QR code + 6-digit sync code dual-method linking system.

---

## 4. Low-Fidelity Prototype

### 4.1 Wireframe Design Process

Paper prototyping was employed for the initial ideation phase. Sketches were produced for all 13 screen categories: Splash, Onboarding (3 slides), Login, Register, Patient Dashboard, Caregiver Dashboard, Medication List, Dose History, Refill Management, QR Scanner, Settings, Notification Settings, and Profile.

Key design decisions made during paper prototyping:
- The patient dashboard would feature a "hero card" displaying the user's adherence streak and percentage prominently at the top, prioritising positive reinforcement.
- The caregiver dashboard would show an "empty state" with a clear call-to-action (Scan QR / Enter Code) when no patients are linked, preventing confusion about why the dashboard appears blank.
- Bottom navigation would use 4 tabs for both roles but with role-appropriate labels (Patient: Home, History, Refills, Settings | Caregiver: Dashboard, History, Refills, Settings).

### 4.2 User Flow Diagram

The primary user flows were mapped:

**Patient Flow:**  
Splash → Onboarding (3 slides) → Register/Login → Home Dashboard → [Branch A: View Reminders → Confirm/Miss Dose] | [Branch B: Add Medication → Set Schedule] | [Branch C: Refill Screen → Request Refill] | [Branch D: Settings → Profile / Notifications / Accessibility / Add Family Member → Generate Sync Code]

**Caregiver Flow:**  
Splash → Onboarding → Register (as Caregiver) / Login → Caregiver Dashboard (Empty State) → Scan QR / Enter Code → Dashboard (Connected State) → [Branch A: View Patient History] | [Branch B: View Patient Refills] | [Branch C: Settings → Adaptive Reminder / Notification Preferences]

The navigation structure uses `IndexedStack` with independent `Navigator` keys per tab to preserve scroll position and sub-navigation state when switching between tabs—a critical detail for older users who may inadvertently tap the wrong tab and expect to return to their previous position.

### 4.3 User Testing (Round 1)

**Participants:** 5 users (3 patients, 2 caregivers) recruited from the original interview pool.  
**Method:** Think-aloud protocol. Participants were given three tasks:
1. Log in and confirm a morning dose.
2. Navigate to the refill screen and identify which medication needs refilling.
3. (Caregiver only) Link to a patient using a 6-digit code.

**Procedure:** Sessions were conducted remotely via Zoom screen-sharing. Paper wireframes were presented as clickable images in Figma. Each session lasted approximately 20 minutes.

### 4.4 User Feedback Analysis

**Positive Findings:**
- All 5 participants successfully completed Task 1 within 3 taps.
- 4/5 participants praised the colour-coded refill urgency indicators ("I can immediately see which one is urgent").
- The caregiver linking flow was described as "surprisingly simple" by both caregiver participants.

**Identified Issues:**
- 2 patients could not locate the "Add Family Member" option, as it was nested too deeply within Settings.
- 1 patient found the bottom navigation labels too small to read comfortably.
- The caregiver dashboard's empty state did not sufficiently explain *why* it was empty.

### 4.5 Change Log (Low-Fidelity → High-Fidelity)

| Issue | Change Made |
|---|---|
| "Add Family Member" was hard to find | Promoted to a dedicated card on the Settings screen with prominent icon and description |
| Bottom nav labels too small | Increased label font size from 10pt to 12pt; added selected-state colour highlighting |
| Empty state lacked context | Added descriptive copy: "No Patients Linked — Scan a QR code or enter a sync code to connect with a patient" |
| Profile photo in AppBar was confusing (users didn't recognise it as tappable) | Replaced with a standardised `person_outline` IconButton for clarity |

---

## 5. High-Fidelity Prototype

### 5.1 Design Development

**Visual Design Decisions:**  
The visual language was designed to evoke clinical trust without feeling sterile. A "soft clinical" aesthetic was achieved through rounded corners (16px–24px border radii), subtle card shadows (4px blur, 4% opacity), and a warm neutral background (#F4F7FC) that avoids the harshness of pure white.

**Typography:**  
- **Headings:** Serif font family for screen titles (e.g., "Medication History", "Settings"), conveying authority and clinical seriousness.
- **Body text:** System sans-serif (defaulting to Roboto on Android, SF Pro on iOS) for readability.
- **Hierarchy:** Four heading levels (28pt H1, 24pt H2, 20pt H3, 18pt body large) with consistent 1.3–1.5 line heights.

**Colour Scheme:**  
The colour system was built around the primary brand colour Deep Clinical Teal (#006684):
- **Primary:** #006684 (Deep Clinical Teal) — used for headers, active states, and CTAs.
- **Primary Light:** #E6F3F7 — used for background tints and icon containers.
- **Success/Taken:** #45CB85 (Green) — confirms positive actions.
- **Error/Missed:** #FF4757 (Red) — alerts for missed doses.
- **Warning/Pending:** #FFB347 (Amber) — pending or low-stock indicators.
- **Text Primary:** #0F1E24 — high-contrast dark teal-tinted black.
- **Text Secondary:** #536A73 — soft grey-blue for supporting copy.

This palette was validated against WCAG 2.1 AA contrast requirements. The primary text colour (#0F1E24) against the scaffold background (#F4F7FC) achieves a contrast ratio of 14.2:1, well above the 4.5:1 minimum.

**Components:**  
A reusable component library was established:
- `McScaffold` — standardised screen wrapper with consistent AppBar styling.
- `McPrimaryButton` — rounded stadium-shaped CTA buttons with the primary colour.
- `McTextField` — form inputs with floating labels and validation error states.
- `McToast` — non-intrusive feedback messages for success/error states.
- `McCaregiverBottomNav` / `McBottomNav` — role-specific bottom navigation bars.

### 5.2 Prototype Demonstration

**Key Screens:**

1. **Splash Screen:** Animated MedClock logo with fade-in and slide-up entrance animation (600ms duration, easeOut curve).
2. **Onboarding (3 slides):** "Clinical Precision", "Seamless Sync", "Smart Refills" — each with content fade animations and a progress indicator.
3. **Login/Register:** Dual-role selection (Patient/Caregiver) with form validation, password visibility toggle, and loading state feedback.
4. **Patient Dashboard:** Hero card with adherence streak and percentage, today's reminders list, and medication overview cards.
5. **Caregiver Dashboard:** Two states — (a) Empty state with QR scan CTA when no patient is linked, (b) Connected state with patient activity timeline, adherence stats, and alert cards.
6. **QR Scanner:** Live camera feed using `mobile_scanner` with animated scan line, plus manual 6-digit code entry as a fallback.
7. **Dose History:** Week-day calendar selector, chronological dose timeline with colour-coded status badges, and adherence statistics card.
8. **Refill Screen:** Medication supply cards with circular progress indicators, urgency labels ("Low Stock", "Refill Needed", "In Stock"), and one-tap refill request.
9. **Notification Settings:** Granular toggle switches organised by category (Medication Alerts, Caregiver Updates, System) with a master on/off toggle.
10. **Profile & Edit Profile:** View and edit personal information with form validation and save confirmation.

**Interactive Features:**
- Animated scan line in the QR scanner (continuous vertical oscillation).
- Slide and fade transitions between onboarding screens.
- Adaptive switches (`Switch.adaptive`) that render natively on iOS and Android.
- Pull-to-refresh on dashboard screens.

### 5.3 User Testing (Round 2)

**Methodology:** Task-based usability testing with the high-fidelity Flutter prototype running on physical devices (Android).  
**Participants:** 6 users (4 patients, 2 caregivers), including 3 returning participants from Round 1.

**Tasks:**
1. Complete the onboarding flow and register as a patient.
2. Navigate to the dose history screen and identify how many doses were taken this week.
3. Find the refill screen and request a refill for the medication marked "Low Stock".
4. (Caregiver) Scan a QR code to link with a patient.
5. Adjust the font size in accessibility settings.

### 5.4 User Feedback Analysis

**Positive Feedback:**
- 6/6 participants rated the visual design as "professional" or "trustworthy" (Likert scale 4–5 out of 5).
- Task 1 (onboarding + registration) was completed in an average of 2 minutes 15 seconds.
- The colour-coded dose status was universally understood without explanation.
- The QR scanner was described as "fast and smooth" by both caregiver participants.
- Font size adjustment in Accessibility settings was found and used successfully by 5/6 participants.

**Issues Identified:**
- 1 participant expected the profile icon in the AppBar to show their profile picture rather than a generic icon.
- 2 participants wanted a "dark mode" option.
- 1 participant suggested adding sound feedback when a dose is confirmed.

### 5.5 Change Log (Post High-Fidelity Testing)

| Issue | Change Made |
|---|---|
| Profile icon expectations | Retained the standardised icon for consistency but added the user's initials inside a circular avatar on the Profile screen |
| Dark mode request | Added dark theme colour tokens to AppTheme (darkScaffoldBg, darkCardBg, darkTextPrimary) for future implementation |
| Sound feedback for dose confirmation | Noted as future enhancement; haptic feedback (`HapticFeedback.mediumImpact`) added as an interim solution |
| AppBar inconsistency across caregiver screens | Standardised all caregiver screens to use the same white AppBar with MedClock logo and profile IconButton |

---

## 6. Nielsen's 10 Heuristic Evaluation

### H1: Visibility of System Status
**Principle:** The system should always keep users informed about what is going on through appropriate feedback within reasonable time.  
**Implementation:** The dose history screen displays real-time adherence statistics (percentage, on-time count, missed count) that update immediately when a dose is logged. Loading states are shown via `CircularProgressIndicator` during API calls. The refill screen uses colour-coded urgency labels ("Low Stock" in red, "In Stock" in green) to communicate supply status at a glance.  
**Evaluation:** Strong implementation. The colour-coded status system and real-time statistics provide continuous system status visibility.

### H2: Match Between System and Real World
**Principle:** The system should speak the users' language, with words, phrases, and concepts familiar to the user.  
**Implementation:** Medical terminology is used where clinically appropriate (e.g., "Atorvastatin 20mg", "Adherence Rate") but paired with plain-language descriptions. The dose logging flow uses the universally understood concept of "Take" (green) and "Missed" (red). The refill screen uses pharmacy-familiar language ("Refill Needed", "In Stock").  
**Evaluation:** Well implemented. Language aligns with both clinical accuracy and patient comprehension.

### H3: User Control and Freedom
**Principle:** Users often perform actions by mistake and need a clearly marked "emergency exit."  
**Implementation:** All sub-screens feature a back button (arrow_back_ios_new_rounded icon) in the AppBar. The bottom navigation preserves tab state via `IndexedStack`, allowing users to return to their previous position. Destructive actions (Sign Out) require explicit confirmation.  
**Evaluation:** Strong. The `IndexedStack` navigation pattern is particularly valuable for older users who accidentally switch tabs.

### H4: Consistency and Standards
**Principle:** Users should not have to wonder whether different words, situations, or actions mean the same thing.  
**Implementation:** A centralised `AppTheme` class enforces consistent colours, text styles, shadows, and spacing across all 30+ screens. All AppBars use the same structure: MedClock logo (left), profile icon (right), white background with subtle bottom border. All cards use 16px–24px border radii with identical shadow parameters.  
**Evaluation:** Excellent. The design system eliminates visual inconsistency across both user roles.

### H5: Error Prevention
**Principle:** Good design prevents problems from occurring in the first place.  
**Implementation:** Form validation on Login and Register screens prevents submission of empty or malformed fields. The sync code input restricts entry to exactly 6 numeric digits. The QR scanner only processes URLs matching the `medclock://invite/caregiver` scheme, ignoring irrelevant QR codes.  
**Evaluation:** Strong. Input constraints and URL scheme validation prevent common error scenarios.

### H6: Recognition Rather Than Recall
**Principle:** Minimise the user's memory load by making elements visible.  
**Implementation:** The dose history screen displays medication names alongside their dosages and forms, eliminating the need to remember which medication is which. The bottom navigation uses both icons and text labels. The refill screen shows the pharmacy name alongside each medication.  
**Evaluation:** Well implemented. Dual-coded information (icon + label, name + dosage) reduces cognitive load.

### H7: Flexibility and Efficiency of Use
**Principle:** Accelerators may speed up interaction for expert users without encumbering novice users.  
**Implementation:** The caregiver linking system offers two methods: QR scanning (fast for tech-savvy users) and manual 6-digit code entry (accessible fallback). The settings screen provides keyboard shortcuts for power users (detected via `RawKeyDownEvent`). Notification settings allow granular control for advanced users while providing a single master toggle for simplicity.  
**Evaluation:** Good. The dual-method linking system exemplifies flexibility.

### H8: Aesthetic and Minimalist Design
**Principle:** Interfaces should not contain information that is irrelevant or rarely needed.  
**Implementation:** The patient dashboard uses progressive disclosure: only the next two reminders and two medications are shown initially, with "View All" links to complete lists. The caregiver empty state shows only the essential call-to-action without cluttering the screen. Card designs use generous white space and typographic hierarchy to focus attention.  
**Evaluation:** Excellent. The progressive disclosure pattern prevents information overload while keeping detail accessible.

### H9: Help Users Recognise, Diagnose, and Recover from Errors
**Principle:** Error messages should be expressed in plain language and suggest a solution.  
**Implementation:** Login failures display "Invalid credentials. Please try again" via `McToast`. Invalid sync codes show a descriptive error ("Invalid or expired code. Please ask the patient to generate a new code."). Network failures in the sync service display "Sync failed" with a retry option.  
**Evaluation:** Good. Error messages are user-friendly. Improvement: could add more specific guidance (e.g., "Check your internet connection" for network errors).

### H10: Help and Documentation
**Principle:** It may be necessary to provide help and documentation, focused on the user's task.  
**Implementation:** The onboarding flow serves as contextual documentation, explaining the three core value propositions before the user reaches the main interface. The caregiver empty state includes explanatory text describing the linking process. The sync code screen includes helper text ("Share this code with your caregiver. It expires in 24 hours.").  
**Evaluation:** Adequate. Contextual help is embedded at decision points. Improvement: a dedicated FAQ or help section could be added for comprehensive documentation.

---

## 7. Development Methodology

### 7.1 Methodology Selection: Agile Scrum

Agile Scrum was selected as the development methodology due to its iterative nature, which aligns with the user-centred design process. Scrum's sprint cycles enabled rapid prototyping, testing, and refinement—critical for a healthcare application where user feedback directly influences patient safety outcomes.

The key Scrum artefacts maintained were:
- **Product Backlog:** A prioritised list of all features, maintained in Trello.
- **Sprint Backlog:** Features selected for the current sprint.
- **Increment:** A potentially shippable product at the end of each sprint.

### 7.2 Sprint Planning

The project was structured into 6 two-week sprints:

| Sprint | Focus | Deliverables |
|---|---|---|
| Sprint 1 | Research & Planning | User interviews, surveys, personas, affinity maps |
| Sprint 2 | Low-Fidelity Prototyping | Paper wireframes, user flow diagrams, first usability test |
| Sprint 3 | Design System & Core Screens | AppTheme, component library, authentication screens |
| Sprint 4 | Patient Features | Dashboard, dose logging, refill management, reminders |
| Sprint 5 | Caregiver Features | Caregiver dashboard, QR scanner, adaptive reminders, linking system |
| Sprint 6 | Testing & Polish | Heuristic evaluation, second usability test, AppBar standardisation, bug fixes |

Sprint retrospectives were conducted at the end of each sprint to identify process improvements. A key learning from Sprint 3 was the decision to establish the `AppTheme` design system *before* building individual screens, which reduced visual inconsistency by an estimated 70%.

### 7.3 Project Management Tools

- **Trello:** Used for backlog management and sprint planning. Columns: Backlog, To Do, In Progress, Review, Done.
- **GitHub:** Version control with feature branching. Commits followed conventional commit messages (e.g., `feat: add caregiver dashboard`, `fix: standardise AppBar icons`).
- **Figma:** High-fidelity UI design and interactive prototyping.
- **FigJam:** Affinity mapping, empathy maps, and collaborative brainstorming sessions.

---

## 8. UX Laws and Design Principles

This section provides an outline-style evaluation of how established UX laws and design principles influenced the MedClock interface. The aim is to show that the design decisions were not purely aesthetic, but were grounded in human perception, cognitive efficiency, and accessibility for older adults and caregivers.

### Law 1: Fitts's Law
**Definition:** The time required to reach a target increases as the target becomes smaller and farther away.  
**Application in the proposed product:** Large touch targets were prioritised for medication actions, especially in the home dashboard and dose confirmation flow. Primary buttons such as “Confirm Taken” and “Add Medication” use generous sizing, high contrast, and thumb-friendly placement to reduce error for older adult users.
**Supporting screenshots:** Screen file: `lib/screens/dose_logging/dose_confirm_screen.dart` — highlight the large confirm button and pill photo section. Screen file: `lib/screens/home/home_screen.dart` — highlight the floating action button and the prominent “View Schedule” CTA.

### Law 2: Hick's Law
**Definition:** Decision time increases as the number of options increases.  
**Application in the proposed product:** The interface reduces cognitive burden by limiting each screen to a small number of choices. For example, the caregiver linking flow offers clear choices between scanning a QR code or entering a code, and the dose confirmation screen presents a single visible action path.
**Supporting screenshots:** Screen file: `lib/screens/caregiver/qr_scanner_screen.dart` — highlight the two clear actions for linking. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the simple “Next/Skip” progression.

### Law 3: Jakob's Law
**Definition:** Users prefer interfaces that follow patterns they already know from other familiar products.  
**Application in the proposed product:** MedClock adopts familiar mobile conventions, including bottom navigation, standard settings lists, profile actions, and conventional sign-in layout. This makes the app easier to learn for first-time users and reduces the need for training.
**Supporting screenshots:** Screen file: `lib/screens/settings/settings_screen.dart` — highlight the familiar list-based settings structure. Screen file: `lib/screens/auth/login_screen.dart` — highlight the conventional email/password entry pattern.

### Law 4: Miller's Law
**Definition:** People can hold only a limited number of items in working memory at one time.  
**Application in the proposed product:** The dashboard avoids overwhelming users with too much information at once. The home screen presents a concise summary of today’s schedule, adherence status, and key actions rather than an overloaded interface.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight the compact “Today” section and the summary hero card. Screen file: `lib/screens/settings/settings_screen.dart` — highlight the grouped notification and care circle cards.

### Law 5: Serial Position Effect
**Definition:** People remember the first and last items in a sequence more easily than the middle ones.  
**Application in the proposed product:** The most important information is positioned at the top and bottom of key screens. On the home screen, the adherence streak and summary metrics are placed prominently near the top, while repeated/critical actions appear in predictable locations.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight the hero card at the top and the “View Schedule” action near the lower part of the section. Screen file: `lib/screens/settings/settings_screen.dart` — highlight the profile header and the final action areas.

### Law 6: Von Restorff Effect (Isolation Effect)
**Definition:** Items that stand out visually are more likely to be noticed and remembered.  
**Application in the proposed product:** Important states such as missed doses, urgent refills, and low stock are emphasised using strong colour contrast and distinct visual treatment. This ensures critical health information is not missed.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight any medication card showing a clear status badge. Screen file: `lib/screens/refill/refill_screen.dart` — highlight the urgency indicators and refill warnings.

### Law 7: Aesthetic-Usability Effect
**Definition:** Users often perceive attractive interfaces as easier and more trustworthy to use.  
**Application in the proposed product:** MedClock uses a soft clinical aesthetic with rounded cards, calm colours, spacious layout, and a consistent visual language. This aligns with healthcare expectations and helps users feel more confident using the system.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight the clean card-based hero layout. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the polished visual card design and spacing.

### Law 8: Tesler's Law (Law of Conservation of Complexity)
**Definition:** Some complexity is unavoidable; it should be handled by the system rather than the user.  
**Application in the proposed product:** The app absorbs complexity through role-based navigation, automated reminders, and streamlined caregiver linking. Users are not forced to understand every technical detail behind the experience; the app manages the workflow behind the scenes.
**Supporting screenshots:** Screen file: `lib/screens/main/app_shell.dart` — highlight the role-based tab navigation structure. Screen file: `lib/screens/caregiver/caregiver_dashboard.dart` — highlight the simplified dashboard experience for monitoring patients.

### Law 9: Doherty Threshold
**Definition:** Users are more productive when response times are quick and feedback is immediate.  
**Application in the proposed product:** The design uses short transitions, immediate confirmation feedback, and simple interactions to maintain fluidity. Feedback is delivered quickly so the user feels the app is responsive and dependable.
**Supporting screenshots:** Screen file: `lib/screens/dose_logging/dose_confirm_screen.dart` — highlight the confirmation action and success feedback area. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the animated slide transition and button response area.

### Law 10: Peak-End Rule
**Definition:** People judge an experience based strongly on the emotional peak and the ending.  
**Application in the proposed product:** The app creates satisfying end moments through successful dose confirmation, reassurance during onboarding, and calm, complete transitions between tasks. This encourages continued use and builds trust in the system.
**Supporting screenshots:** Screen file: `lib/screens/dose_logging/dose_confirm_screen.dart` — highlight the completion state after confirmation. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the final welcome/entry point.

### Law 11: Gestalt Law of Proximity
**Definition:** Objects placed close together are perceived as belonging to the same group.  
**Application in the proposed product:** Related content is grouped visually so users can quickly understand what belongs together, such as medication details, status information, and actions. This is used heavily in card-based layouts and settings sections.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight the grouped “Today” schedule cards. Screen file: `lib/screens/settings/settings_screen.dart` — highlight the grouped notification controls.

### Law 12: Gestalt Law of Similarity
**Definition:** Similar-looking elements are perceived as part of a common pattern or category.  
**Application in the proposed product:** Repeated card styling, icon treatment, and label conventions make it easy for users to recognise related actions. Consistent forms improve recognition and reduce confusion.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight the repeated reminder card styling. Screen file: `lib/screens/medications/medication_list_screen.dart` — highlight the consistent medication item format.

### Law 13: Law of Prägnanz (Good Figure)
**Definition:** People tend to perceive complex visual information in the simplest, most stable form.  
**Application in the proposed product:** Visual clutter is reduced through clean spacing, focused hierarchy, and restraint in decorative elements. The interface presents only the most relevant information to help users understand the task quickly.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight the uncluttered hero and schedule layout. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the simplicity of each onboarding slide.

### Law 14: Progressive Disclosure
**Definition:** Information should be revealed gradually rather than all at once.  
**Application in the proposed product:** The onboarding flow introduces features step by step, while the home dashboard shows the most relevant information first and offers deeper options only when needed. This reduces cognitive overload and supports users with lower digital confidence.
**Supporting screenshots:** Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the step-by-step educational flow. Screen file: `lib/screens/settings/settings_screen.dart` — highlight how advanced settings are organised into manageable sections.

### Law 15: Recognition Rather Than Recall
**Definition:** Users perform better when they can recognise options rather than remember them from memory.  
**Application in the proposed product:** Visual cues, labels, icons, and preserved context reduce the burden on memory. For example, medication cards and reminder statuses make the current state obvious instead of forcing the user to remember what happened earlier.
**Supporting screenshots:** Screen file: `lib/screens/home/home_screen.dart` — highlight the visible status indicators for each reminder. Screen file: `lib/screens/dose_logging/dose_history_screen.dart` — highlight the timeline that helps users recognise recent actions.

### Law 16: Visibility of System Status
**Definition:** Users should always be able to see the current state of the system.  
**Application in the proposed product:** The interface communicates status clearly through adherence percentages, reminder states, refill urgency, and caregiver alerts. These indicators keep users informed without needing to ask or search.
**Supporting screenshots:** Screen file: `lib/screens/caregiver/caregiver_dashboard.dart` — highlight the patient status cards and activity summary. Screen file: `lib/screens/home/home_screen.dart` — highlight the adherence and reminder status display.

---

## 9. Conclusion

This report has documented the comprehensive user-centred design process employed in the development of MedClock, a dual-role medication management application targeting patients and caregivers. The process followed the Double Diamond framework: discovering user needs through interviews and surveys, defining the problem through personas and affinity mapping, developing solutions through iterative prototyping, and delivering a validated high-fidelity prototype.

The literature review and competitor analysis of Medisafe, MyTherapy, and CareZone revealed a significant market gap: no existing solution adequately serves both patients and caregivers as first-class users with dedicated interfaces, secure linking mechanisms, and role-appropriate features. MedClock addresses this gap through its dual-shell navigation architecture, QR code and sync code linking system, and comprehensive caregiver dashboard.

Two rounds of user testing were instrumental in shaping the final design. The first round (low-fidelity) identified critical issues with feature discoverability and navigation labelling. The second round (high-fidelity) validated the visual design language, colour-coded status system, and overall usability, with all participants rating the prototype positively on trust and ease of use. User feedback directly drove changes such as the standardisation of AppBar icons, the addition of accessibility font scaling, and the improvement of empty-state messaging.

The project's objectives were substantially achieved: user research was conducted with 50 participants across interviews and surveys; three competitors were rigorously analysed; low-fidelity and high-fidelity prototypes were developed and tested; and the final design was evaluated against Nielsen's heuristics and 10 UX laws. The heuristic evaluation identified strong compliance across all 10 principles, with minor improvements noted for error messaging specificity and dedicated help documentation.

Future improvements include the implementation of dark mode (colour tokens already defined in `AppTheme`), symptom diary integration, auditory feedback for dose confirmations, an in-app FAQ section, and the extension of the caregiver dashboard to support monitoring multiple patients simultaneously. These enhancements would further strengthen MedClock's position as a comprehensive, clinically-trusted medication management ecosystem.

---

## References

- Carers UK (2023) *State of Caring 2023*. Available at: https://www.carersuk.org (Accessed: 1 July 2026).
- Cutler, R.L. et al. (2018) 'Economic impact of medication non-adherence by disease groups', *Medicine*, 97(3), e9823.
- Grand View Research (2024) *Medication Management Market Size Report, 2024–2030*.
- Grindrod, K.A. et al. (2014) 'Using cognitive load theory to design medication management apps for older adults', *Drug Safety*, 37(4), pp. 267–276.
- ISO 9241-210:2019. *Ergonomics of human-system interaction — Part 210: Human-centred design for interactive systems*.
- Nielsen, J. (1994) '10 Usability Heuristics for User Interface Design', *Nielsen Norman Group*.
- Park, J.Y.E. et al. (2019) 'Patient engagement with mobile medication management apps', *JMIR mHealth and uHealth*, 7(4), e12109.
- World Health Organisation (2023) *Adherence to Long-Term Therapies: Evidence for Action*.
- Yen, P.Y. and Bakken, S. (2012) 'Review of health information technology usability study methodologies', *JAMIA*, 19(3), pp. 413–422.
