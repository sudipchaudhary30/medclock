# MedClock — UX Laws and Design Principles Outline

This document outlines how established UX laws and design principles influenced the MedClock interface. The purpose is to show that the product’s design choices were guided by human behaviour, cognitive load reduction, accessibility, and trust.

## 1. Fitts’s Law
- Definition: The time required to reach a target increases as the target becomes smaller and farther away.
- Application in the proposed product: Large touch targets were prioritised for medication actions and key navigation elements to make the interface easier to use for older adults.
- Supporting screenshots: Screen file: `lib/screens/dose_logging/dose_confirm_screen.dart` — highlight the large confirmation button and pill photo area. Screen file: `lib/screens/home/home_screen.dart` — highlight the floating action button and the prominent primary action.

## 2. Hick’s Law
- Definition: Decision time increases as the number of options increases.
- Application in the proposed product: The interface reduces cognitive overload by limiting choices at each step, especially in onboarding and caregiver linking.
- Supporting screenshots: Screen file: `lib/screens/caregiver/qr_scanner_screen.dart` — highlight the two clear linking options. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the simple “Next/Skip” flow.

## 3. Jakob’s Law
- Definition: Users prefer interfaces that follow patterns they already know from familiar products.
- Application in the proposed product: MedClock uses common mobile patterns such as bottom navigation, list-based settings, and standard sign-in layouts.
- Supporting screenshots: Screen file: `lib/screens/settings/settings_screen.dart` — highlight the familiar settings list. Screen file: `lib/screens/auth/login_screen.dart` — highlight the conventional login layout.

## 4. Miller’s Law
- Definition: People can hold only a limited number of items in working memory at one time.
- Application in the proposed product: The interface presents concise summaries rather than large amounts of information so users do not feel overloaded.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight the compact “Today” section and summary card. Screen file: `lib/screens/settings/settings_screen.dart` — highlight grouped settings cards.

## 5. Serial Position Effect
- Definition: People remember the first and last items in a sequence more easily.
- Application in the proposed product: Key information is positioned prominently at the top or bottom of the screen for better recall and recognition.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight the top hero card and clear action areas.

## 6. Von Restorff Effect
- Definition: Items that stand out visually are more likely to be noticed.
- Application in the proposed product: Missed doses, low stock, and urgent refill states are highlighted with strong colour contrast so they are immediately noticed.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight visible reminder status badges. Screen file: `lib/screens/refill/refill_screen.dart` — highlight urgency indicators.

## 7. Aesthetic-Usability Effect
- Definition: Users often perceive attractive interfaces as easier and more trustworthy to use.
- Application in the proposed product: The app uses a calm clinical visual style with rounded cards, consistent spacing, and trustworthy colours.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight the polished hero card layout. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the clean visual presentation.

## 8. Tesler’s Law
- Definition: Some complexity is unavoidable; the system should absorb it rather than the user.
- Application in the proposed product: Role-based navigation and automated reminders reduce the burden of managing medication tasks manually.
- Supporting screenshots: Screen file: `lib/screens/main/app_shell.dart` — highlight the role-specific navigation structure. Screen file: `lib/screens/caregiver/caregiver_dashboard.dart` — highlight the simplified monitoring interface.

## 9. Doherty Threshold
- Definition: Users are more productive when response times are quick and feedback is immediate.
- Application in the proposed product: The design supports fast transitions and immediate confirmation feedback to keep the experience smooth.
- Supporting screenshots: Screen file: `lib/screens/dose_logging/dose_confirm_screen.dart` — highlight the confirmation action and feedback state.

## 10. Peak-End Rule
- Definition: People judge an experience based strongly on the emotional peak and the final moments.
- Application in the proposed product: The app aims to end key interactions positively through successful confirmations and reassuring onboarding transitions.
- Supporting screenshots: Screen file: `lib/screens/dose_logging/dose_confirm_screen.dart` — highlight the completion state after dose confirmation. Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the final transition into the welcome stage.

## 11. Gestalt Law of Proximity
- Definition: Objects placed close together are seen as part of the same group.
- Application in the proposed product: Related content such as reminder details and status are grouped visually to improve readability.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight the grouped schedule cards. Screen file: `lib/screens/settings/settings_screen.dart` — highlight grouped settings controls.

## 12. Gestalt Law of Similarity
- Definition: Similar-looking elements are perceived as part of the same category.
- Application in the proposed product: Consistent card styles, labels, and icons help users recognise repeated actions and patterns easily.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight the repeated reminder card style. Screen file: `lib/screens/medications/medication_list_screen.dart` — highlight consistent medication item formatting.

## 13. Law of Prägnanz
- Definition: People tend to perceive complex visuals in the simplest and most stable form.
- Application in the proposed product: The interface uses clean spacing and clear hierarchy to minimise visual clutter.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight the uncluttered hero and schedule layout.

## 14. Progressive Disclosure
- Definition: Information should be revealed gradually instead of all at once.
- Application in the proposed product: Onboarding and settings are presented step by step so users are not overwhelmed by too many options.
- Supporting screenshots: Screen file: `lib/screens/onboarding/onboarding_screen.dart` — highlight the step-by-step onboarding flow. Screen file: `lib/screens/settings/settings_screen.dart` — highlight the organised sections.

## 15. Recognition Rather Than Recall
- Definition: Users perform better when they can recognise options instead of remembering them.
- Application in the proposed product: Visual cues, labels, and visible statuses make the current state obvious and reduce memory load.
- Supporting screenshots: Screen file: `lib/screens/home/home_screen.dart` — highlight reminder status indicators. Screen file: `lib/screens/dose_logging/dose_history_screen.dart` — highlight the timeline for recent actions.

## 16. Visibility of System Status
- Definition: Users should always be able to see the current state of the system.
- Application in the proposed product: The app shows adherence status, reminder progress, and caregiver activity so users know what is happening at a glance.
- Supporting screenshots: Screen file: `lib/screens/caregiver/caregiver_dashboard.dart` — highlight patient status cards and recent activity. Screen file: `lib/screens/home/home_screen.dart` — highlight adherence and reminder status display.
