import Foundation
import Combine

/// Global session + onboarding state. Kept deliberately small. Anything that
/// needs to persist across launches lives in UserDefaults here or in SwiftData
/// models; ephemeral per-session state lives here in memory.
@MainActor
final class AppState: ObservableObject {
    @Published var hasFinishedOnboarding: Bool
    @Published var isAuthenticated: Bool
    @Published var userId: String?
    @Published var contactEmail: String?
    @Published var contactPhone: String?

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let onboardingDone = "housebrief.onboardingDone"
        static let userId = "housebrief.userId"
        static let email = "housebrief.email"
        static let phone = "housebrief.phone"
    }

    init() {
        let storedUserId = defaults.string(forKey: Keys.userId)
        self.hasFinishedOnboarding = defaults.bool(forKey: Keys.onboardingDone)
        self.userId = storedUserId
        self.contactEmail = defaults.string(forKey: Keys.email)
        self.contactPhone = defaults.string(forKey: Keys.phone)
        self.isAuthenticated = storedUserId != nil
    }

    func finishOnboarding(email: String, phone: String) {
        contactEmail = email
        contactPhone = phone
        hasFinishedOnboarding = true
        defaults.set(email, forKey: Keys.email)
        defaults.set(phone, forKey: Keys.phone)
        defaults.set(true, forKey: Keys.onboardingDone)
    }

    func completeAuthentication(userId: String) {
        self.userId = userId
        isAuthenticated = true
        hasFinishedOnboarding = true
        defaults.set(userId, forKey: Keys.userId)
        defaults.set(true, forKey: Keys.onboardingDone)
    }

    func signOut() {
        userId = nil
        isAuthenticated = false
        hasFinishedOnboarding = false
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.email)
        defaults.removeObject(forKey: Keys.phone)
        defaults.set(false, forKey: Keys.onboardingDone)
    }
}
