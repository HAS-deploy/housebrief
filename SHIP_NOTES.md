# HouseBrief — Portfolio Audit Fix Notes (2026-05-15)

Audit reference: `/Users/tony/Documents/portfolio-audit/07-housebrief.md`
(2 HARD, 4 SIGNIFICANT, 3 POLISH)

## Summary

**2 HARDs fixed, 0 SIGNIFICANTs fixed, 0 POLISH fixed, 5 DEFERRED.**

Scope intentionally tight per owner instruction: fix the two HARD findings
(silently swallowed submit errors + missing server-id reconciliation) and
defer everything else. No StoreKit changes (app is free / no IAP). No
version bump, no build, no push.

## Fixed

### H1 — Submit API failures no longer shown as success
**Files:** `HouseBrief/Features/Submit/SubmitFlowView.swift`

Before: local record was inserted with `status = .submitted`, wizard
dismissed at line 91, success haptic fired at line 94 — all before the
network call returned. Failures hit `print("submit API failed: \(error)")`
and the user saw a fake success row in My Properties even though the lead
never reached the acquisition team.

After:
- Local record is inserted as `.draft` only.
- Wizard stays open with a "Sending your submission…" overlay until
  the API call returns.
- On success: `remoteId` is stored, status is flipped to `.submitted`,
  success haptic fires, wizard dismisses.
- On failure: an alert surfaces the error with **Retry** / **Keep as
  draft** options. The local record stays `.draft` so the user can
  see it in My Properties and try again.
- Added analytics event `submission.failed` with `state_code` so the
  failure rate is visible in PostHog.

### H2 — Server submissionId now persisted; statuses reconcile on refresh
**Files:**
- `HouseBrief/Core/Models/PropertySubmission.swift` — added
  `var remoteId: String?` (optional, SwiftData lightweight migration safe).
- `HouseBrief/Features/Submit/SubmitFlowView.swift` — stores
  `resp.submissionId` into `submission.remoteId` on successful submit.
- `HouseBrief/Features/Properties/PropertiesListView.swift` — added
  `.refreshable { await refreshStatuses() }` and a `.task` first-load
  pull. Calls `APIClient.shared.listMine()`, builds a `remoteId -> status`
  map, and upserts `statusRaw` for any local record whose server status
  has changed.

The App Store description's status-update promise ("Submitted / Under
Review / Review Complete / Contact Requested / Not a Fit Right Now") is
now actually deliverable via pull-to-refresh.

## Deferred

### S1 — "Multi-step submission flow" is actually one Form with five sections
**DEFERRED — needs owner.** The audit notes the code itself flags this
at SubmitFlowView.swift:99: *"Stage-1 wizard — one screen with all
fields for a buildable skeleton. Stage-4 polish will split this into
proper paged wizard steps."* Splitting the Form into five paged steps
with per-step validation and a progress indicator is >30 minutes of
careful UI work (and touches the wizard state model). Two paths for
the owner:
  1. **Code path:** split `SubmitWizardView` into a `TabView` with
     `.tabViewStyle(.page)` or a step counter + `NavigationStack`
     pushes per step.
  2. **ASC metadata path:** edit the App Store description from
     "Multi-step submission flow — address, property basics, condition,
     situation, timeline" to "Guided form with five sections — address,
     property basics, condition, situation, timeline." Faster, no code
     risk, still accurate.

### S2 — 5-state list not surfaced in onboarding; state-code is free TextField
**DEFERRED — needs owner.** Affects funnel UX but is not a 2.3.1
violation (the form does enforce). Recommend in onboarding page 2 or 3
listing "TX / TN / OH / MO / IN today" and converting the State
TextField in SubmitWizardView to a `Picker` limited to the 5 launch
states + an "Other → notify me" path. ~20-30 minutes; deferred to keep
this pass purely HARD-focused.

### S3 — Status copy collapses `.underReview` / `.needMoreInfo` / `.contactRequested` to one generic line
**DEFERRED — needs owner.** Quick to fix in `Copy.swift` +
`PropertiesListView.bodyForStatus`, but pairs naturally with H2 once
the owner sees how status payloads actually look in production. Add
distinct copy for those three statuses; `.contactRequested` deserves a
CTA pointing to Messages.

### S4 — `FollowUpEngine` is dead code; `followUpAnswers` relationship never populated
**DEFERRED — needs owner.** Either delete `Core/Rules/FollowUpEngine.swift`
(5KB) and the `followUpAnswers` SwiftData relationship, or wire it.
Not a reviewer risk; pure dead-code cleanup. Out of scope for this
pass (touches the SwiftData schema relationships — could affect data
load).

### P1 / P2 / P3 — polish items
**DEFERRED — needs owner.** All three are non-blocking. P1 (account
deletion local SwiftData wipe + surfaced server-delete error) is the
most user-visible; recommend pairing with the next paywall/settings
review.

## ASC metadata edits (owner action, no code)

- **S1 description rewrite (optional, alternative to building the paged
  wizard):** change "Multi-step submission flow — address, property
  basics, condition, situation, timeline" to "Guided form with five
  sections — address, property basics, condition, situation, timeline."

## Risk notes

- `PropertySubmission` now has a new optional `remoteId: String?`. SwiftData
  handles new optional properties as a lightweight migration — existing
  on-device submissions will load with `remoteId == nil` and the
  refresh path simply skips them (no remote id to match). Safe.
- The refresh path (`refreshStatuses`) only runs when
  `AuthStore.shared.token != nil`. First-launch users with no token
  won't hit the API. Safe.
- `Retry` in the wizard re-invokes `onComplete(submission)` with the
  same `PropertySubmission` instance. `context.insert(_:)` on an
  already-inserted model is a no-op in SwiftData, so this doesn't
  duplicate the record. Verified by inspection.
- Analytics event `submission.failed` is new — confirm in PostHog
  schema that ad-hoc events are accepted (project already uses ad-hoc
  property bags on `submission.submitted`).

## Build / submit

**NOT performed.** Per portfolio guidelines: commit only, no push, no
version bump, no `xcodebuild`, no ASC submission. Owner will batch-build
in the serial phase.
