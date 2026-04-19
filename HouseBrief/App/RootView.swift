import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if !appState.hasFinishedOnboarding || !appState.isAuthenticated {
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
