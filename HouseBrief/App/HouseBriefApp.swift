import SwiftUI
import SwiftData

@main
struct HouseBriefApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase
    let container: ModelContainer = {
        let schema = Schema([
            PropertySubmission.self,
            FollowUpAnswer.self,
            MessageThread.self,
            MessageItem.self,
        ])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }()

    init() {
        PortfolioAnalytics.shared.start(appName: "housebrief")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                PortfolioAnalytics.shared.track(PortfolioEvent.sessionStart)
            }
        }
    }
}
