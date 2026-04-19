import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var page = 0

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
                appState.finishOnboarding(email: email, phone: phone)
                appState.completeAuthentication(userId: UUID().uuidString)
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

private struct OnboardingPage: View {
    let title: String
    let message: String
    let cta: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(title).font(.largeTitle).bold().multilineTextAlignment(.center)
            Text(message).font(.body).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(cta, action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
            Text(Copy.universalDisclosure)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

private struct OnboardingContactPage: View {
    let onDone: (_ email: String, _ phone: String) -> Void
    @State private var email = ""
    @State private var phone = ""
    @State private var isUsProperty = false

    private var canContinue: Bool {
        email.contains("@") && phone.filter(\.isNumber).count >= 10 && isUsProperty
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

            Button("Continue") { onDone(email, phone) }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!canContinue)

            Text(Copy.universalDisclosure)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(24)
    }
}
