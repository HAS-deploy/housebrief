import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        // Show onboarding until the user finishes the welcome flow; we don't
        // gate on `isAuthenticated` because the user token is issued by the
        // server on their first real submission, not up front.
        if !appState.hasFinishedOnboarding {
            OnboardingFlowView()
        } else {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            SubmitFlowView()
                .tabItem { Label("Submit", systemImage: "plus.circle.fill") }

            PropertiesListView()
                .tabItem { Label("My Properties", systemImage: "house.fill") }

            MessagesListView()
                .tabItem { Label("Messages", systemImage: "envelope.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
