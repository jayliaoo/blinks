# Roadmap: Blinks

**Version:** 1.0
**Goal:** Replace eye drop reminder Done/Snooze buttons with adaptive feeling-based interval control.

## Phase 1: Adaptive Eye Drop Reminder

**Goal:** Replace Done/Snooze buttons with "Not Good"/"Good" buttons that adapt reminder interval based on user comfort feedback.

**Requirements:** EYE-01, EYE-02, EYE-03

**Success Criteria:**
1. Eye drop reminder window displays two feeling buttons (Not Good / Good) instead of Done/Snooze
2. After tapping "Not Good", next reminder arrives at half the configured interval
3. After tapping "Good", next reminder arrives at the user-configured interval
4. Interval adapts correctly across multiple reminder cycles without drift

**Changes:**
- `EyeDropReminderWindow.swift` — Replace view and callbacks
- `AppDelegate.swift` — Add adaptive interval logic, update timer restart

---
*Last updated: 2026-05-15 after initialization*
