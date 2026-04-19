import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    LabeledContent("Email") { Text(appState.contactEmail ?? "—") }
                    LabeledContent("Phone") { Text(appState.contactPhone ?? "—") }
                }
                Section("About") {
                    LabeledContent("Version", value: Bundle.main.marketingVersion)
                    Link("Privacy policy", destination: Copy.privacyPolicyURL)
                    Link("Terms of use", destination: Copy.termsURL)
                    Link("Support", destination: Copy.supportURL)
                }
                Section("Notice") {
                    Text(Copy.universalDisclosure).font(.caption).foregroundStyle(.secondary)
                }
                Section("Account") {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("Delete account and data")
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete account?",
                                isPresented: $showDeleteConfirm,
                                titleVisibility: .visible) {
                Button("Delete everything", role: .destructive) {
                    appState.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes your contact info and sign-out from this device. Submissions are kept for audit but anonymized.")
            }
        }
    }
}

extension Bundle {
    var marketingVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}
