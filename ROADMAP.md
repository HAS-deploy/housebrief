# HouseBrief — Growth Roadmap

This is the phased plan. Each phase has concrete gating criteria — don't advance until the gate is green. Keep the consumer app free across all phases. All monetization happens on the business side.

## Phase 1 — Consumer intake (NOW · weeks 1-2)

**What ships**
- iOS app (free) for sellers to submit a property and track status.
- AWS backend on DR account: submit / list / detail / state-check / delete-account endpoints.
- Admin dashboard (internal only) with queue, detail, Claude analysis, status controls, audit log.
- State rules engine: TX / TN / OH / MO / IN enabled. Everything else politely blocked.
- Best-effort legal docs (Terms + Privacy) published. Banner explicitly says "not reviewed by counsel."

**Revenue target**
- $0 MRR. Consumer side is free forever. Monetization happens after acquisitions close.

**Gate to advance to Phase 2a**
- [ ] ASC approval + live on App Store
- [ ] 25+ real seller submissions received
- [ ] Claude analysis working reliably in production (no compliance-linter trips in 100 runs)
- [ ] Zero incidents involving state-licensing concerns

## Phase 2a — Stabilize + observe (weeks 2-12)

**What happens**
- Run the intake pipeline. Review every submission. Do NOT send written offers until counsel has reviewed a per-state contract template.
- Informal outreach ("we'd like to talk about your property") is fine. Formal offers are not.
- Track submission volume, state breakdown, acquisition candidates, pass rate, time-to-respond.
- Observe whether regulators or attorneys ever contact us. If they do, pause, consult, adjust.

**Revenue target**
- Still $0 MRR from the app. Any revenue is downstream from actual home purchases — not within scope of this roadmap.

**Gate to advance to Phase 2b**
- [ ] 60-90 days of steady submission flow
- [ ] At least one state confirms our intake framing holds up (no cease-and-desist, no inquiries)
- [ ] Internal acquisitions team has processed enough deals to define a repeatable buy-box
- [ ] Licensed real-estate attorney engaged in launch states (at minimum TX + one other) to review: (a) Terms of Use §3 §6 §14 §15; (b) per-state disclosures; (c) purchase-agreement + assignment template

## Phase 2b — Legal foundation + buyer portal scaffold (weeks 12-16)

**What happens**
- Attorney review completes. Documents published in final form. Banner updated.
- Scaffold `housebrief-buyers` repo — Next.js web app (separate from iOS). Deployed to AWS DR (S3 + CloudFront). Not distributed via App Store — web-only keeps us outside 3.1.1 IAP scrutiny.
- Stripe Billing integration. Plans created (see Phase 3 ladder).
- Buyer onboarding flow: invite-only waitlist, email verification, proof-of-funds upload (S3 with SSE), buy-box preferences, state preferences.
- Admin: buyer approval workflow + per-deal distribution controls.
- Backend: `deal_opportunities` table + distribution logic. Every deal shown is audit-logged per buyer.

**Revenue target**
- Still $0 MRR. Plumbing only. No signups yet.

**Gate to advance to Phase 3**
- [ ] Attorney signs off on buyer-portal Terms of Service + distribution mechanics
- [ ] State rules engine extended with per-state `buyer_marketing_sensitivity` — deals in high-sensitivity states don't distribute
- [ ] POF verification workflow works end-to-end
- [ ] First 2-3 deals controlled by our acquisition entity and available to distribute

## Phase 3 — Open buyer portal (months 4-6)

**What ships**
- Invite-only signups open. Paid tiers via Stripe, monthly + annual:

| Tier | Price | Gate |
|---|---|---|
| Individual | $99/mo or $999/yr | 1 state · POF ≤ $250k · email-only alerts |
| Pro | $299/mo or $2,999/yr | 3 states · POF ≤ $1M · SMS + 24h priority · spreadsheet export |
| Fund | $1,499/mo or $15,000/yr | unlimited states · POF ≥ $5M · API access · named Slack/email channel |

**Revenue target**
- 20 Pro buyers = **~$6k MRR** at 6-month mark
- Stretch: 40 Pro + 5 Fund = **~$19.5k MRR** by month 9

**Gate to advance to Phase 4**
- [ ] $10k+ MRR with low churn (<8%)
- [ ] Deal distribution never triggered a state regulator complaint
- [ ] Backend proven at 500+ concurrent buyer sessions
- [ ] Internal ops team (acquisitions + compliance + dispo) has defined clear per-deal review SLA

## Phase 4 — Acquisitions ops scale (months 6-12)

**What ships**
- Automated title-check integration (e.g., Qualia, Endpoint, or similar).
- Inspection-vendor API integration.
- Buyer-side: saved-search alerts, deal watchlist, on-deal-details bidding/expression-of-interest UI.
- Admin-side: pipeline dashboard, acquisitions-team KPIs, per-state P&L breakdown.
- Expand enabled states (compliance-gated). Default pace: 1-2 new states per quarter.

**Revenue target**
- **$30-60k MRR** from buyer portal by month 12
- Acquisition volume = funding requirements met without outside capital

**Gate to advance to Phase 5**
- [ ] Buyer-portal NPS sustained > 40
- [ ] Deal-close rate > 25% of acquisition candidates
- [ ] Hire a General Counsel (in-house or fractional) — lawyer costs should be < 2% of acquisitions P&L

## Phase 5 — Institutional + API (year 2+)

**What ships**
- Fund-tier API for automated deal ingestion by institutional buyers.
- Multi-user buyer accounts (team seats).
- Deal provenance / chain-of-custody audit exports for fund due-diligence teams.
- Consumer app: optional iOS-side SIWA upgrade + universal links for deeper attribution.
- Possible Android build (only if consumer-side data shows demand).

**Revenue target**
- **$150k+ MRR** sustained
- Buyer portal pays for the whole operating company (engineering + acquisitions + compliance)

## What we will NOT do (ever)

These lines are defense-in-depth against being reclassified as a broker / unlicensed wholesaler / unlicensed marketplace:

- No commission or success fee of any kind charged to sellers.
- No consumer-facing paid tier on the iOS app.
- No public-facing listing feed or "browse homes" marketplace view.
- No buyer-to-seller messaging. Sellers interact only with our acquisitions team.
- No distributing submissions we haven't placed under contract or obtained assignable rights on.
- No state-by-state expansion without compliance sign-off.

## Tracking growth

Keep a simple `GROWTH.md` in the acquisitions team's private repo (not this one). Monthly entries:
- Submissions received (by state)
- Acquisition candidates identified
- Offers extended
- Contracts signed
- Deals assigned (to buyer network)
- Deals closed by acquisition entity
- Buyer-portal MRR + active buyers + churn
- Any compliance / regulatory signals

This roadmap is living — expect the phases to adjust based on real-world signals, not the other way around.
