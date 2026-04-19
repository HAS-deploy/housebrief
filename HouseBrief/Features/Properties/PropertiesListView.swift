import SwiftUI
import SwiftData

struct PropertiesListView: View {
    @Query(sort: \PropertySubmission.createdAt, order: .reverse) private var submissions: [PropertySubmission]

    var body: some View {
        NavigationStack {
            Group {
                if submissions.isEmpty {
                    ContentUnavailableView(
                        "No submissions yet",
                        systemImage: "house",
                        description: Text("Tap Submit to add your first property.")
                    )
                } else {
                    List(submissions) { s in
                        NavigationLink(destination: PropertyDetailView(submission: s)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(s.displayAddress).font(.headline)
                                HStack {
                                    Text(s.status.displayText)
                                        .font(.caption)
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(Color.accentColor.opacity(0.15))
                                        .clipShape(Capsule())
                                    Text(s.createdAt, style: .date)
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Properties")
        }
    }
}

struct PropertyDetailView: View {
    let submission: PropertySubmission

    var body: some View {
        Form {
            Section {
                Text(submission.displayAddress).font(.headline)
                Text(submission.status.displayText).font(.subheadline).foregroundStyle(.secondary)
            }
            Section("Status") {
                Text(bodyForStatus(submission.status))
            }
            Section("Details") {
                LabeledContent("Type") {
                    Text((PropertyType(rawValue: submission.propertyTypeRaw) ?? .singleFamily).displayText)
                }
                if let beds = submission.beds { LabeledContent("Bedrooms", value: "\(beds)") }
                if let baths = submission.baths { LabeledContent("Bathrooms", value: String(format: "%.1f", baths)) }
                LabeledContent("Condition", value: "\(submission.conditionScore)/5")
                LabeledContent("Occupancy") {
                    Text((Occupancy(rawValue: submission.occupancyRaw) ?? .unknown).displayText)
                }
                LabeledContent("Timeline") {
                    Text((Timeline(rawValue: submission.timelineRaw) ?? .flexible).displayText)
                }
            }
            Section {
                Text(Copy.universalDisclosure).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Submission")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bodyForStatus(_ status: SubmissionStatus) -> String {
        switch status {
        case .submitted: return Copy.statusSubmittedBody
        case .reviewComplete: return Copy.statusReviewCompleteBody
        case .notAFit: return Copy.statusNotAFitBody
        case .draft: return "This submission is still a draft."
        default: return "Under review by our acquisition team."
        }
    }
}
