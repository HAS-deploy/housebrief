import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var page = 0
    @State private var startedAt: Date = Date()
    @State private var stepEnteredAt: Date = Date()

    private static let stepNames = ["intro", "principal", "contact"]
    private static let stepTotal = stepNames.count

    var body: some View {
        TabView(selection: $page) {
            OnboardingPage(title: Copy.onboardingIntroTitle,
                           message: Copy.onboardingIntroBody,
                           cta: "Continue") { page = 1 }
                .tag(0)
            OnboardingPage(title: Copy.onboardingPrincipalTitle,
                           message: Copy.onboardingPrincipalBody,
                           cta: "I understand") { page = 2 }
                .tag(1)
            OnboardingContactPage { email, phone in
                // Mark onboarding done but do NOT issue a user id yet —
                // the server will mint one during the first submit and
                // we'll store it from the response (APIClient + SubmitFlowView).
                PortfolioAnalytics.shared.track(PortfolioEvent.onboardingCompleted, [
                    "total_seconds": Int(Date().timeIntervalSince(startedAt)),
                    "steps_skipped": 0,
                ])
                appState.finishOnboarding(email: email, phone: phone)
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear {
            startedAt = Date()
            stepEnteredAt = startedAt
            PortfolioAnalytics.shared.track(PortfolioEvent.onboardingStarted)
            trackViewed(page: 0)
        }
        .onChange(of: page) { oldValue, newValue in
            let now = Date()
            PortfolioAnalytics.shared.track(PortfolioEvent.onboardingAdvanced, [
                "from_step": Self.stepName(oldValue),
                "to_step": Self.stepName(newValue),
                "seconds_on_step": Int(now.timeIntervalSince(stepEnteredAt)),
            ])
            stepEnteredAt = now
            trackViewed(page: newValue)
        }
    }

    private func trackViewed(page: Int) {
        PortfolioAnalytics.shared.track(PortfolioEvent.onboardingViewed, [
            "step": Self.stepName(page),
            "step_index": page,
            "step_total": Self.stepTotal,
        ])
    }

    private static func stepName(_ index: Int) -> String {
        guard index >= 0, index < stepNames.count else { return "unknown" }
        return stepNames[index]
    }
}

private struct OnboardingPage: View {
    let title: String
    let message: String
    let cta: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(title).font(.largeTitle).bold().multilineTextAlignment(.center)
            Text(message).font(.body).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text(Copy.universalDisclosure)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(cta, action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
            // Bottom breathing room so the TabView page-indicator dots
            // don't overlap our CTA.
            Spacer().frame(height: 28)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}

private struct OnboardingContactPage: View {
    let onDone: (_ email: String, _ phone: String) -> Void
    @State private var email = ""
    @State private var phone = ""
    @State private var isUsProperty = false

    private var canContinue: Bool {
        isValidEmail(email)
            && phone.filter(\.isNumber).count >= 10
            && isUsProperty
    }

    private func isValidEmail(_ s: String) -> Bool {
        // Minimal well-formed check. Not RFC-perfect, just tight enough to
        // catch the common typos (missing @, missing TLD) without dragging
        // in a regex engine for v1.
        guard s.count >= 5, let at = s.firstIndex(of: "@") else { return false }
        let local = s[s.startIndex..<at]
        let domain = s[s.index(after: at)..<s.endIndex]
        return !local.isEmpty && domain.contains(".") && !domain.hasSuffix(".")
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(Copy.onboardingUsOnlyTitle).font(.largeTitle).bold()
            Text(Copy.onboardingUsOnlyBody)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                TextField("Phone", text: $phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.top, 8)

            Toggle("My property is in the United States.", isOn: $isUsProperty)
                .toggleStyle(.switch)

            Text(Copy.universalDisclosure)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Continue") { onDone(email, phone) }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!canContinue)
            Spacer().frame(height: 28)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}
