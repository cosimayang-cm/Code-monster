//
//  StorageClientTests.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import XCTest
import ComposableArchitecture
@testable import CodeMonster

final class StorageClientTests: XCTestCase {

    var storageClient: StorageClient!
    let testKey = "test_monster5_interactions"

    override func setUp() {
        super.setUp()
        // Create a test storage client with custom key
        storageClient = StorageClient(
            saveInteraction: { interaction in
                let defaults = UserDefaults.standard
                var all: [Int: PostInteraction] = [:]
                if let data = defaults.data(forKey: self.testKey),
                   let decoded = try? JSONDecoder().decode([Int: PostInteraction].self, from: data) {
                    all = decoded
                }
                all[interaction.postId] = interaction
                let data = try JSONEncoder().encode(all)
                defaults.set(data, forKey: self.testKey)
            },
            loadInteraction: { postId in
                let defaults = UserDefaults.standard
                guard let data = defaults.data(forKey: self.testKey),
                      let decoded = try? JSONDecoder().decode([Int: PostInteraction].self, from: data) else {
                    return nil
                }
                return decoded[postId]
            },
            loadAllInteractions: {
                let defaults = UserDefaults.standard
                guard let data = defaults.data(forKey: self.testKey),
                      let decoded = try? JSONDecoder().decode([Int: PostInteraction].self, from: data) else {
                    return [:]
                }
                return decoded
            }
        )
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        super.tearDown()
    }

    // MARK: - T037

    func testStorageClientWhenSaveAndLoadThenDataPersists() throws {
        let interaction = PostInteraction(postId: 1, isLiked: true, likeCount: 5, commentCount: 3, shareCount: 2)

        // Save interaction
        try storageClient.saveInteraction(interaction)

        // Load interaction
        let loaded = try storageClient.loadInteraction(1)

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.postId, 1)
        XCTAssertEqual(loaded?.isLiked, true)
        XCTAssertEqual(loaded?.likeCount, 5)
        XCTAssertEqual(loaded?.commentCount, 3)
        XCTAssertEqual(loaded?.shareCount, 2)
    }

    // MARK: - T038

    func testStorageClientWhenLoadAllThenReturnsAllInteractions() throws {
        let interaction1 = PostInteraction(postId: 1, isLiked: true, likeCount: 5, commentCount: 3, shareCount: 2)
        let interaction2 = PostInteraction(postId: 2, isLiked: false, likeCount: 0, commentCount: 1, shareCount: 0)

        // Save multiple interactions
        try storageClient.saveInteraction(interaction1)
        try storageClient.saveInteraction(interaction2)

        // Load all interactions
        let all = try storageClient.loadAllInteractions()

        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all[1], interaction1)
        XCTAssertEqual(all[2], interaction2)
    }
}
