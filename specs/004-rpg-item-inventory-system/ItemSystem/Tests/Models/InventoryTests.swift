import XCTest
@testable import ItemSystem

final class InventoryTests: XCTestCase {

    var sut: Inventory!

    override func setUp() {
        super.setUp()
        sut = Inventory(capacity: 5)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createTestItem(slot: EquipmentSlot = .helmet, affixType: AffixType = .attack) -> Item {
        let template = ItemTemplate(
            templateId: "test_\(slot.rawValue)_001",
            name: "Test Item",
            description: "Test",
            slot: slot,
            rarity: .rare,
            levelRequirement: 1,
            baseStats: Stats()
        )
        return Item(
            template: template,
            mainAffix: Affix(type: affixType, value: 100, isPercentage: false),
            subAffixes: []
        )
    }

    // MARK: - T049: testInventoryAddWhenNotFullThenReturnsTrue

    func testInventoryAddWhenNotFullThenReturnsTrue() {
        // Given
        let item = createTestItem()

        // When
        let result = sut.add(item)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.count, 1)
        XCTAssertTrue(sut.contains(item))
    }

    // MARK: - T050: testInventoryAddWhenFullThenReturnsFalse

    func testInventoryAddWhenFullThenReturnsFalse() {
        // Given
        for i in 0..<5 {
            let item = createTestItem(slot: EquipmentSlot.allCases[i % 5])
            sut.add(item)
        }
        let extraItem = createTestItem()

        // When
        let result = sut.add(extraItem)

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(sut.count, 5)
        XCTAssertTrue(sut.isFull)
    }

    // MARK: - T051: testInventoryRemoveWhenItemExistsThenReturnsTrue

    func testInventoryRemoveWhenItemExistsThenReturnsTrue() {
        // Given
        let item = createTestItem()
        sut.add(item)

        // When
        let result = sut.remove(item)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.contains(item))
    }

    // MARK: - T052: testInventoryFilterByAffixMaskWhenMatchAllThenReturnsMatchingItems

    func testInventoryFilterByAffixMaskWhenMatchAllThenReturnsMatchingItems() {
        // Given
        let attackItem = createTestItem(slot: .helmet, affixType: .attack)
        let defenseItem = createTestItem(slot: .body, affixType: .defense)
        let critItem = createTestItem(slot: .gloves, affixType: .crit)
        sut.add(attackItem)
        sut.add(defenseItem)
        sut.add(critItem)

        // When
        let attackItems = sut.filter(byAffixMask: .attack, matchAll: true)
        let offensiveItems = sut.filter(byAffixMask: .offensive, matchAll: false)

        // Then
        XCTAssertEqual(attackItems.count, 1)
        XCTAssertEqual(attackItems.first?.instanceId, attackItem.instanceId)

        // offensive = [.crit, .attack, .elementalDamage]
        XCTAssertEqual(offensiveItems.count, 2) // attack + crit
    }

    // MARK: - Additional Tests

    func testInventoryRemoveWhenItemNotExistsThenReturnsFalse() {
        // Given
        let item = createTestItem()
        // 不加入背包

        // When
        let result = sut.remove(item)

        // Then
        XCTAssertFalse(result)
    }

    func testInventoryGetItemByIdWhenExistsThenReturnsItem() {
        // Given
        let item = createTestItem()
        sut.add(item)

        // When
        let found = sut.getItem(byId: item.instanceId)

        // Then
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.instanceId, item.instanceId)
    }

    func testInventoryAvailableSpaceWhenPartiallyFilledThenReturnsCorrectValue() {
        // Given
        sut.add(createTestItem(slot: .helmet))
        sut.add(createTestItem(slot: .body))

        // When
        let space = sut.availableSpace

        // Then
        XCTAssertEqual(space, 3)
    }
}
