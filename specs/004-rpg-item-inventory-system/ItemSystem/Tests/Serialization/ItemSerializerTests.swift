import XCTest
@testable import ItemSystem

final class ItemSerializerTests: XCTestCase {

    var sut: ItemSerializer!

    override func setUp() {
        super.setUp()
        sut = ItemSerializer()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createTestItem() -> Item {
        let template = ItemTemplate(
            templateId: "test_helmet_001",
            name: "測試頭盔",
            description: "測試用",
            slot: .helmet,
            rarity: .epic,
            levelRequirement: 10,
            baseStats: Stats(attack: 0, defense: 50, maxHP: 200)
        )

        let mainAffix = Affix(type: .hp, value: 500, isPercentage: false)
        let subAffixes = [
            Affix(type: .attack, value: 10, isPercentage: true),
            Affix(type: .defense, value: 15, isPercentage: true),
            Affix(type: .crit, value: 5, isPercentage: true)
        ]

        return Item(template: template, mainAffix: mainAffix, subAffixes: subAffixes)
    }

    // MARK: - T074: testItemSerializerEncodeWhenValidItemThenReturnsJsonData

    func testItemSerializerEncodeWhenValidItemThenReturnsJsonData() throws {
        // Given
        let item = createTestItem()

        // When
        let data = try sut.encode(item)

        // Then
        XCTAssertFalse(data.isEmpty)

        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("instanceId"))
        XCTAssertTrue(jsonString!.contains("templateId"))
        XCTAssertTrue(jsonString!.contains("mainAffix"))
    }

    // MARK: - T075: testItemSerializerDecodeWhenValidJsonThenReturnsItem

    func testItemSerializerDecodeWhenValidJsonThenReturnsItem() throws {
        // Given
        let originalItem = createTestItem()
        let data = try sut.encode(originalItem)

        // When
        let decodedItem = try sut.decode(data)

        // Then
        XCTAssertEqual(decodedItem.instanceId, originalItem.instanceId)
        XCTAssertEqual(decodedItem.templateId, originalItem.templateId)
        XCTAssertEqual(decodedItem.level, originalItem.level)
        XCTAssertEqual(decodedItem.mainAffix.type, originalItem.mainAffix.type)
        XCTAssertEqual(decodedItem.subAffixes.count, originalItem.subAffixes.count)
    }

    // MARK: - T076: testItemSerializerRoundTripWhenEncodeThenDecodeThenEqual

    func testItemSerializerRoundTripWhenEncodeThenDecodeThenEqual() throws {
        // Given
        let originalItem = createTestItem()
        originalItem.levelUp()
        originalItem.levelUp()

        // When
        let jsonString = try sut.encodeToString(originalItem)
        let decodedItem = try sut.decodeFromString(jsonString)

        // Then
        XCTAssertEqual(decodedItem.instanceId, originalItem.instanceId)
        XCTAssertEqual(decodedItem.level, 3) // 初始 1 + 2 次升級
        XCTAssertEqual(decodedItem.affixMask, originalItem.affixMask)
    }

    // MARK: - Additional Tests

    func testItemSerializerDecodeWhenInvalidJsonThenThrows() {
        // Given
        let invalidData = "{ not valid json }".data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try sut.decode(invalidData))
    }
}
