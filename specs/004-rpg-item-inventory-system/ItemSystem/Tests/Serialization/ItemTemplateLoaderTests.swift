import XCTest
@testable import ItemSystem

final class ItemTemplateLoaderTests: XCTestCase {

    var sut: ItemTemplateLoader!

    override func setUp() {
        super.setUp()
        sut = ItemTemplateLoader()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - T073: testItemTemplateLoaderLoadWhenValidJsonThenReturnsTemplate

    func testItemTemplateLoaderLoadWhenValidJsonThenReturnsTemplate() throws {
        // Given
        let json = """
        [
            {
                "templateId": "test_helmet_001",
                "name": "測試頭盔",
                "description": "測試用",
                "slot": "helmet",
                "rarity": "rare",
                "levelRequirement": 5,
                "baseStats": {
                    "attack": 0,
                    "defense": 20,
                    "maxHP": 100,
                    "maxMP": 0,
                    "critRate": 0,
                    "critDamage": 0,
                    "speed": 0
                },
                "attributes": [],
                "setId": null,
                "iconAsset": null,
                "modelAsset": null
            }
        ]
        """

        // When
        let templates = try sut.load(from: json)

        // Then
        XCTAssertEqual(templates.count, 1)
        XCTAssertEqual(templates.first?.templateId, "test_helmet_001")
        XCTAssertEqual(templates.first?.name, "測試頭盔")
        XCTAssertEqual(templates.first?.slot, .helmet)
        XCTAssertEqual(templates.first?.rarity, .rare)
        XCTAssertEqual(templates.first?.levelRequirement, 5)
        XCTAssertEqual(templates.first?.baseStats.defense, 20)
    }

    func testItemTemplateLoaderLoadWhenInvalidJsonThenThrows() {
        // Given
        let invalidJson = "{ invalid json }"

        // When/Then
        XCTAssertThrowsError(try sut.load(from: invalidJson))
    }
}
