//
//  StorageClient.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import Foundation
import ComposableArchitecture

/// Local storage client for persisting post interaction data
@DependencyClient
struct StorageClient: Sendable {
    var saveInteraction: @Sendable (PostInteraction) throws -> Void
    var loadInteraction: @Sendable (_ postId: Int) throws -> PostInteraction?
    var loadAllInteractions: @Sendable () throws -> [Int: PostInteraction]
}

// MARK: - Live Implementation

extension StorageClient: DependencyKey {
    static let liveValue: StorageClient = {
        let key = "monster5_interactions"

        return StorageClient(
            saveInteraction: { interaction in
                let defaults = UserDefaults.standard
                var all = (try? Self.decodeInteractions(from: defaults, key: key)) ?? [:]
                all[interaction.postId] = interaction
                let data = try JSONEncoder().encode(all)
                defaults.set(data, forKey: key)
            },
            loadInteraction: { postId in
                let defaults = UserDefaults.standard
                let all = (try? Self.decodeInteractions(from: defaults, key: key)) ?? [:]
                return all[postId]
            },
            loadAllInteractions: {
                let defaults = UserDefaults.standard
                return (try? Self.decodeInteractions(from: defaults, key: key)) ?? [:]
            }
        )
    }()

    private static func decodeInteractions(from defaults: UserDefaults, key: String) throws -> [Int: PostInteraction] {
        guard let data = defaults.data(forKey: key) else { return [:] }
        return try JSONDecoder().decode([Int: PostInteraction].self, from: data)
    }
}

// MARK: - Test Implementation

extension StorageClient: TestDependencyKey {
    static let testValue = StorageClient()
}

// MARK: - Dependency Registration

extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
