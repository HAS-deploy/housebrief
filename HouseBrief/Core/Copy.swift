import Foundation

/// Every user-facing string lives here so the compliance linter can scan them
/// in one sweep. Do not inline copy in views — add it here and reference it.
enum Copy {

    // MARK: - Onboarding
    static let onboardingIntroTitle = "Submit your house for review."
    static let onboardingIntroBody = """
    HouseBrief is a free way to tell a private home-buying company about your property. We review what you share and reach out if we're interested in making a direct cash offer.
    """

    static let onboardingPrincipalTitle = "We are a principal buyer."
    static let onboardingPrincipalBody = """
    We are not a real estate broker, agent, or representative. We don't find buyers or market your home. If we make an offer, it's from our own affiliated acquisition entity as a direct cash buyer. You're free to accept, decline, or negotiate.
    """

    static let onboardingUsOnlyTitle = "U.S. properties only."
    static let onboardingUsOnlyBody = """
    HouseBrief is available only for properties located in the United States. We review submissions in a limited set of states today and plan to expand as our team grows.
    """

    // MARK: - Submit
    static let submitHeroTitle = "Tell us about your house."
    static let submitHeroBody = "A few quick questions about the property. Our team reviews every submission and follows up directly."

    // MARK: - Disclosures (always visible)
    static let universalDisclosure = """
    We are a private home-buying company (principal buyer). We are not a real estate broker, agent, or representative. Submission does not guarantee an offer. Availability depends on your property, market conditions, title review, and state eligibility.
    """

    static let acknowledgementItems: [String] = [
        "I understand HouseBrief is a private home-buying company, not a broker or agent.",
        "I understand submitting does not guarantee an offer.",
        "I understand if HouseBrief enters a contract, they may close themselves or assign their contract rights where lawful.",
        "I'm submitting information about a property in the United States.",
    ]

    // MARK: - Status
    static let statusSubmittedBody = "We've received your submission. Our acquisition team will review it and follow up."
    static let statusReviewCompleteBody = "Review complete. Check your messages for next steps."
    static let statusNotAFitBody = "After review, we're not able to pursue this property right now. No further action is needed. Thanks for submitting."

    // MARK: - Blocked state
    static func blockedStateMessage(stateName: String) -> String {
        "We're not currently buying in \(stateName). You can leave your info and we'll reach out if that changes. No pressure."
    }

    // MARK: - Push templates (rendered by server; mirrored here for linting)
    static let pushFollowUp = "We have a quick follow-up on your property submission. Open HouseBrief when you have a moment."
    static let pushStatusChanged = "Your submission status has updated. Tap to see the latest."

    // MARK: - Legal links
    static let privacyPolicyURL = URL(string: "https://has-deploy.github.io/housebrief/privacy-policy.html")!
    static let termsURL = URL(string: "https://has-deploy.github.io/housebrief/terms.html")!
    static let supportURL = URL(string: "https://has-deploy.github.io/housebrief/support.html")!

    static let supportEmail = "tony@medbillresolve.com"
}
