import SwiftUI
import SwiftData

@main
struct HouseBriefApp: App {
    @StateObject private var appState = AppState()
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

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
        .modelContainer(container)
    }
}
