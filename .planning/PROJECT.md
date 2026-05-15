# Blinks

## What This Is

Blinks is a macOS menu bar application that helps reduce eye strain through full-screen blink animation reminders and eye drop reminder notifications with snooze functionality.

## Core Value

Keep users' eyes healthy by delivering reliable, timely reminders for blinking and eye drops.

## Requirements

### Validated

- ✓ Menu bar app with eye icon and status menu — existing
- ✓ Full-screen blink animation reminder — existing
- ✓ Eye drop reminder with snooze and done buttons — existing
- ✓ Blink interval/duration/opacity settings — existing
- ✓ Eye drop interval configuration — existing
- ✓ Launch at login support — existing
- ✓ Pause/resume functionality — existing
- ✓ Sleep/wake handling — existing

### Active

- [ ] EYE-01: Replace Done/Snooze buttons with "Not Good" / "Good" feeling buttons in eye drop reminder
- [ ] EYE-02: "Not Good" halves next reminder interval (one-time reduction)
- [ ] EYE-03: "Good" restores next reminder interval to user-configured value

### Out of Scope

- Mobile app — macOS only, menu bar focused
- Continuous interval halving — user confirmed one-time reduction only

## Context

Brownfield Swift/SwiftUI macOS app. Central logic lives in `AppDelegate.swift`, eye drop reminder UI in `EyeDropReminderWindow.swift`. All state uses `@AppStorage` on AppDelegate (ObservableObject). Zero test coverage.

## Constraints

- **Tech stack**: Swift 5 + SwiftUI + AppKit — no third-party dependencies
- **Minimum macOS**: 13.0
- **Single file changes**: Only `EyeDropReminderWindow.swift` and `AppDelegate.swift` need modification

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Replace Done/Snooze with Good/Not Good feeling buttons | User wants adaptive interval based on eye comfort feedback | — Pending |
| "Not Good" halves interval once (not continuously) | Prevents runaway rapid reminders | — Pending |
| "Good" resets to user-configured interval | Respects user's preference when they feel fine | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-15 after initialization*
