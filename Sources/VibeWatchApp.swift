import SwiftUI

@main
struct VibeWatchApp: App {
    @State private var watcher: BlueskyWatcher

    init() {
        let w = BlueskyWatcher()
        _watcher = State(initialValue: w)
        w.start()
    }

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 0) {
                if watcher.posts.isEmpty {
                    Text("No matching posts yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(watcher.posts.prefix(30)) { post in
                                Button {
                                    if let url = post.webURL {
                                        NSWorkspace.shared.open(url)
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(post.authorName).fontWeight(.semibold)
                                            Text("@\(post.authorHandle)")
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                            Text(post.createdAt, style: .relative)
                                                .foregroundStyle(.secondary)
                                        }
                                        .font(.caption)
                                        Text(post.text)
                                            .font(.caption)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                Divider().padding(.horizontal, 12)
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                }
                Divider()
                HStack {
                    Text("\(watcher.posts.count) posts \u{00B7} polling every 30s")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .frame(width: 380)
            .onAppear { watcher.markRead() }
        } label: {
            Image(systemName: watcher.hasNew ? "bubble.left.fill" : "bubble.left")
        }
        .menuBarExtraStyle(.window)
    }
}
