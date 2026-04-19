# HouseBrief — App Store Review Notes

_Paste this (or a condensed version) into ASC → App Information → App Review Information → Notes before submitting._

## What the app does

HouseBrief is a free intake app for a private home-buying company (an affiliated "Acquisition Entity"). U.S. homeowners use it to submit information about a property they may want to sell. Our internal acquisitions team reviews each submission and, if we're interested, reaches out directly to the seller outside the app to discuss a possible direct cash offer.

## What the app is NOT

- Not a real estate broker, agent, representative, or fiduciary
- Not a listing service or marketplace
- Not a matchmaker between buyers and sellers
- Not a marketing platform for homes

Every user-facing string is scanned by a compiled-in compliance linter (`HouseBrief/Core/Rules/ComplianceLinter.swift`) that fails the build if forbidden language (broker / realtor / agent / listing / guaranteed offer / market your home / etc.) appears in shipped copy. Negation-aware — "not a broker" passes; "we are a broker" fails.

## Sign in with Apple (Guideline 4.8)

HouseBrief does NOT use any third-party or social login service (no Facebook / Google / Apple / Twitter / Amazon / WeChat login, no OAuth). Users provide an email + phone on the last onboarding screen; a stateless, per-install HMAC-signed token is issued by our backend on the first submission. This is a first-party credential, not a third-party or social login — so 4.8 does not apply.

If the review team reads 4.8 more expansively: we will add Sign in with Apple as an equivalent option in a follow-up release. Nothing about our model requires or prefers a third-party identity; we are happy to offer SIWA.

## Account deletion (Guideline 5.1.1(v))

Settings → Delete account and data. This calls `DELETE /v1/account` on our backend, which (a) anonymizes the user's contact info, (b) sets `deletedAt` on the user profile, and (c) causes every subsequent token-authed request to return **401 Unauthorized**. Submissions themselves are anonymized but retained per our Privacy Policy's 7-year real-estate recordkeeping requirement.

## State availability

HouseBrief is U.S.-only. The app currently accepts submissions from TX, TN, OH, MO, IN. Submissions from any other U.S. state show a polite "we're not currently buying in your state" message and are not written to our backend. Submissions from outside the U.S. are not possible — the app is built around U.S. ZIP + 2-letter state.

## Privacy policy + terms

- Privacy Policy: https://has-deploy.github.io/housebrief/privacy-policy.html
- Terms of Use:   https://has-deploy.github.io/housebrief/terms.html
- Support:        https://has-deploy.github.io/housebrief/support.html

All three are live and return HTTP 200. Disclosures explicitly cover:
- No brokerage / agency / fiduciary relationship
- Submission is not a contract
- Assignment of contract rights only where permitted by state law
- AI-assisted review via Anthropic Claude commercial API (not used for training)

## Business model + monetization

HouseBrief is free to download and use. There is no in-app purchase, no subscription, no paywall. We do not charge sellers any commission, success fee, or service charge. Our revenue comes from closing real-world home purchases as a principal buyer and, where lawful, assigning purchase agreements for an assignment fee disclosed to both parties. None of that revenue flows through the iOS app.

## How to test

Demo account is not required — the app auto-signs up from email + phone on the last onboarding screen.

1. Launch the app. Tap through the 3 onboarding pages (Submit / Principal-buyer disclosure / U.S. confirm + contact).
2. On the third page, enter email = `reviewer@test.example`, phone = `5125551234`, toggle "My property is in the United States." → Continue.
3. You arrive at the Main tab view. Tap **Submit** → **Start a submission**.
4. Fill in:
   - Street: `100 Main St`
   - City: `Austin`
   - State: `TX` (enabled)
   - ZIP: `78701`
   - Beds / Baths / Condition — any values
   - Timeline — any
   - Toggle all 4 acknowledgements.
5. Tap **Submit**. The submission is sent to our backend and appears in My Properties.
6. Test blocked-state UX: open a new submission, set State = `CA`. You'll see the "we're not currently buying in California" message and Submit remains disabled.
7. Test account deletion: Settings → Delete account and data → Delete everything. The app returns to onboarding. A follow-up call to any authed endpoint returns 401.

## Technical notes

- Backend: AWS (Lambda + HTTP API Gateway + DynamoDB + S3 + Anthropic Claude). URL: https://v5h4vig89k.execute-api.us-east-1.amazonaws.com
- Local data: SwiftData. User token: Keychain (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`).
- No third-party analytics SDKs. No ad SDKs. No tracking.
- No precise location, camera, microphone, photo library, or contacts access in v1.
- Export compliance: `ITSAppUsesNonExemptEncryption = false` (standard HTTPS + Keychain only).

## Contact

- Review contact: Tony McMurtrey
- Email: tony@medbillresolve.com
- Phone: +1 (210) 210-6034
