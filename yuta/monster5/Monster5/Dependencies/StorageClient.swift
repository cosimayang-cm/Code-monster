import Foundation
import ComposableArchitecture

@DependencyClient
struct StorageClient: Sendable {
    var loadInteractions: @Sendable () -> [Int: PostInteraction] = { [:] }
    var saveInteractions: @Sendable ([Int: PostInteraction]) -> Void
}

extension StorageClient: DependencyKey {
    static let liveValue: Self = .init(
        loadInteractions: {
            guard let data = UserDefaults.standard.data(forKey: "postInteractions"),
                  let interactions = try? JSONDecoder().decode([Int: PostInteraction].self, from: data)
            else { return [:] }
            return interactions
        },
        saveInteractions: { interactions in
            guard let data = try? JSONEncoder().encode(interactions) else { return }
            UserDefaults.standard.set(data, forKey: "postInteractions")
        }
    )
}

extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
