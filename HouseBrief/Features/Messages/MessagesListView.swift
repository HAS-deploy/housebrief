import SwiftUI
import SwiftData

struct MessagesListView: View {
    @Query(sort: \MessageThread.lastActivityAt, order: .reverse) private var threads: [MessageThread]

    var body: some View {
        NavigationStack {
            Group {
                if threads.isEmpty {
                    ContentUnavailableView(
                        "No messages",
                        systemImage: "envelope",
                        description: Text("Messages from our acquisition team about your submissions appear here.")
                    )
                } else {
                    List(threads) { t in
                        NavigationLink(destination: MessageThreadView(thread: t)) {
                            VStack(alignment: .leading) {
                                Text(t.subject).font(.headline)
                                Text(t.lastActivityAt, style: .relative)
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Messages")
        }
    }
}

struct MessageThreadView: View {
    let thread: MessageThread

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(thread.items.sorted(by: { $0.sentAt < $1.sentAt })) { item in
                    HStack {
                        if item.author == .user { Spacer(minLength: 40) }
                        Text(item.body)
                            .padding(10)
                            .background(item.author == .user
                                        ? Color.accentColor.opacity(0.2)
                                        : Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        if item.author == .acquisitions { Spacer(minLength: 40) }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(thread.subject)
        .navigationBarTitleDisplayMode(.inline)
    }
}
