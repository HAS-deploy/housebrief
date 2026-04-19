import SwiftUI
import SwiftData

struct SubmitFlowView: View {
    @Environment(\.modelContext) private var context
    @State private var showingWizard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(Copy.submitHeroTitle).font(.largeTitle).bold()
                Text(Copy.submitHeroBody)
                    .font(.body).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                Button("Start a submission") { showingWizard = true }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                Spacer()
                Text(Copy.universalDisclosure)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .navigationTitle("Submit")
            .sheet(isPresented: $showingWizard) {
                SubmitWizardView { submission in
                    context.insert(submission)
                    try? context.save()
                    showingWizard = false
                }
            }
        }
    }
}

/// Stage-1 wizard — one screen with all fields for a buildable skeleton.
/// Stage-4 polish will split this into proper paged wizard steps.
struct SubmitWizardView: View {
    let onComplete: (PropertySubmission) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var submission = PropertySubmission()
    @State private var acknowledged = Set<Int>()

    private var stateAllowed: Bool {
        submission.stateCode.count == 2
            && StateRulesEngine.canSubmit(stateCode: submission.stateCode)
    }
    private var allAcknowledged: Bool {
        acknowledged.count == Copy.acknowledgementItems.count
    }
    private var canSubmit: Bool {
        stateAllowed
            && !submission.addressLine1.isEmpty
            && !submission.city.isEmpty
            && submission.zip.count == 5
            && allAcknowledged
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Address") {
                    TextField("Street address", text: $submission.addressLine1)
                    TextField("Apt / unit (optional)", text: $submission.addressLine2)
                    TextField("City", text: $submission.city)
                    TextField("State (e.g. TX)", text: $submission.stateCode)
                        .textCase(.uppercase)
                        .onChange(of: submission.stateCode) { _, v in
                            submission.stateCode = String(v.uppercased().prefix(2))
                        }
                    TextField("ZIP", text: $submission.zip)
                        .keyboardType(.numberPad)
                        .onChange(of: submission.zip) { _, v in
                            submission.zip = String(v.filter(\.isNumber).prefix(5))
                        }
                    if submission.stateCode.count == 2 && !stateAllowed {
                        let name = StateRulesEngine.usStateNames[submission.stateCode]
                            ?? submission.stateCode
                        Text(Copy.blockedStateMessage(stateName: name))
                            .font(.footnote).foregroundStyle(.orange)
                    }
                }

                Section("Property") {
                    Picker("Property type", selection: Binding(
                        get: { PropertyType(rawValue: submission.propertyTypeRaw) ?? .singleFamily },
                        set: { submission.propertyTypeRaw = $0.rawValue }
                    )) {
                        ForEach(PropertyType.allCases) { t in Text(t.displayText).tag(t) }
                    }
                    Stepper("Bedrooms: \(submission.beds ?? 0)",
                            value: Binding(get: { submission.beds ?? 0 },
                                           set: { submission.beds = $0 == 0 ? nil : $0 }),
                            in: 0...20)
                    Stepper("Bathrooms: \(submission.baths ?? 0, specifier: "%.1f")",
                            value: Binding(get: { submission.baths ?? 0 },
                                           set: { submission.baths = $0 == 0 ? nil : $0 }),
                            in: 0...20, step: 0.5)
                    Picker("Condition", selection: $submission.conditionScore) {
                        Text("Needs major work (1)").tag(1)
                        Text("Needs work (2)").tag(2)
                        Text("Average (3)").tag(3)
                        Text("Good (4)").tag(4)
                        Text("Excellent (5)").tag(5)
                    }
                    TextField("Known repairs (optional)",
                              text: $submission.repairNotes, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section("Situation") {
                    Picker("Occupancy", selection: Binding(
                        get: { Occupancy(rawValue: submission.occupancyRaw) ?? .unknown },
                        set: { submission.occupancyRaw = $0.rawValue }
                    )) {
                        ForEach(Occupancy.allCases) { o in Text(o.displayText).tag(o) }
                    }
                    Toggle("Inherited / family property", isOn: $submission.flagInherited)
                    Toggle("In probate or estate", isOn: $submission.flagProbate)
                    Toggle("Behind on payments", isOn: $submission.flagBehindOnPayments)
                    Toggle("Tax or lien concerns", isOn: $submission.flagTaxOrLien)
                    Toggle("Code violation notices", isOn: $submission.flagCodeViolation)
                }

                Section("Timeline") {
                    Picker("How soon?", selection: Binding(
                        get: { Timeline(rawValue: submission.timelineRaw) ?? .flexible },
                        set: { submission.timelineRaw = $0.rawValue }
                    )) {
                        ForEach(Timeline.allCases) { t in Text(t.displayText).tag(t) }
                    }
                }

                Section("Acknowledgements") {
                    ForEach(Array(Copy.acknowledgementItems.enumerated()), id: \.offset) { i, text in
                        Toggle(text, isOn: Binding(
                            get: { acknowledged.contains(i) },
                            set: { on in
                                if on { acknowledged.insert(i) } else { acknowledged.remove(i) }
                            }
                        ))
                        .toggleStyle(.switch)
                    }
                    Text(Copy.universalDisclosure)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New submission")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Submit") {
                        submission.status = .submitted
                        submission.updatedAt = .now
                        onComplete(submission)
                    }
                    .disabled(!canSubmit)
                }
            }
        }
    }
}
