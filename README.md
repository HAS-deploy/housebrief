# HouseBrief

iOS app: U.S. homeowners submit a property for review by a private home-buying company. **Principal buyer only. Not a broker or agent.** All surfaces and copy are designed to keep us on the principal-buyer side of state licensing lines.

## Ground rules

- **No broker language.** The `ComplianceLinter` (CI gate) scans every shipped copy constant; any occurrence of `broker`, `realtor`, `agent`, `guaranteed offer`, `market your home`, etc. fails the build unless it's inside a negation ("not a broker").
- **U.S. only.** `StateRulesEngine` gates per-state. Launch set: TX / TN / OH / MO / IN. All others blocked in v1.
- **Legal foundation is a prerequisite to App Store submission**, not to scaffold. Licensed real-estate counsel must review: Terms, disclosures, state rules table, contract assignment language. Do NOT submit without this step.

## Build

```
cd ~/Developer/housebrief
xcodegen generate
xcodebuild -project HouseBrief.xcodeproj -scheme HouseBrief \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test
```

14 tests should pass.

## Architecture

- `HouseBrief/App/` — entrypoint, `AppState`, `RootView`, `MainTabView`
- `HouseBrief/Core/Models/` — SwiftData: `PropertySubmission`, `SubmissionPhoto`, `FollowUpAnswer`, `MessageThread`, `MessageItem`
- `HouseBrief/Core/Rules/` — `StateRulesEngine` (per-state gating), `ComplianceLinter` (forbidden-language guard), `FollowUpEngine` (rules-based question-picker)
- `HouseBrief/Core/Copy.swift` — every user-facing string lives here so the linter scans it in one sweep
- `HouseBrief/Features/` — Onboarding / Submit / Properties / Messages / Settings
- `HouseBriefTests/` — compliance linter, state rules, follow-up engine

## Backend (not in this repo)

The iOS app is stage-1 standalone with a SwiftData local store. A separate repo (`housebrief-api` — not yet created) holds the Node/Fastify/Postgres/S3 backend + admin dashboard. The follow-up engine in this repo mirrors the server logic for offline demos; server is authoritative when wired up.

## Growth roadmap

Phased plan with explicit gating criteria between phases: see [ROADMAP.md](ROADMAP.md).

TL;DR — Phase 1 consumer intake (now) → Phase 2a stabilize for 60-90 days → Phase 2b attorney review + scaffold buyer portal → Phase 3 open paid buyer signups ($99 / $299 / $1,499 per month tiers) → Phase 4 ops scale → Phase 5 institutional API. Monetization is entirely on the business side; consumer iOS app stays free forever.

## Compliance sensitivity

This is a regulated corridor. If copy, data flow, state enablement, or contract-assignment logic changes, run:

1. `xcodebuild test` — compliance linter must stay green
2. Attorney review — any change to disclosures, per-state rules, or product claims
3. Stage 4 of `~/Documents/app-factory-workflow.md` before submit
