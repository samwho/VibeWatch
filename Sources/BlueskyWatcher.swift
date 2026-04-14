import Foundation
import Observation

struct BSPost: Identifiable, Sendable {
    let id: String
    let authorHandle: String
    let authorName: String
    let text: String
    let createdAt: Date
    let rkey: String

    var webURL: URL? {
        URL(string: "https://bsky.app/profile/\(authorHandle)/post/\(rkey)")
    }
}

@MainActor
@Observable
final class BlueskyWatcher {
    var posts: [BSPost] = []
    var hasNew = false
    private var seenIDs: Set<String> = []
    private var started = false

    func start() {
        guard !started else { return }
        started = true
        Task {
            while !Task.isCancelled {
                await search()
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }

    func markRead() {
        hasNew = false
    }

    private func search() async {
        var components = URLComponents(string: "https://public.api.bsky.app/xrpc/app.bsky.feed.searchPosts")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "vibe code menu bar claude"),
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "sort", value: "latest"),
        ]
        guard let url = components.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let rawPosts = json["posts"] as? [[String: Any]] else { return }

            let fmt = ISO8601DateFormatter()
            fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            var matched: [BSPost] = []

            for raw in rawPosts {
                guard let uri = raw["uri"] as? String,
                      let author = raw["author"] as? [String: Any],
                      let handle = author["handle"] as? String,
                      let record = raw["record"] as? [String: Any],
                      let text = record["text"] as? String,
                      let indexedAt = raw["indexedAt"] as? String else { continue }

                let low = text.lowercased()
                guard (low.contains("vibe code") || low.contains("vibecode"))
                        && (low.contains("menu bar") || low.contains("menubar"))
                        && low.contains("claude") else { continue }

                matched.append(BSPost(
                    id: uri,
                    authorHandle: handle,
                    authorName: (author["displayName"] as? String) ?? handle,
                    text: text,
                    createdAt: fmt.date(from: indexedAt) ?? .distantPast,
                    rkey: uri.components(separatedBy: "/").last ?? ""
                ))
            }

            let newIDs = Set(matched.map(\.id))
            if !seenIDs.isEmpty && !newIDs.subtracting(seenIDs).isEmpty {
                hasNew = true
            }
            seenIDs.formUnion(newIDs)
            posts = matched.sorted { $0.createdAt > $1.createdAt }
        } catch {
            // retry next cycle
        }
    }
}
