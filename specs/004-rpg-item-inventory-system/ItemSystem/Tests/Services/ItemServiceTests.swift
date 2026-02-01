import XCTest
@testable import ItemSystem

final class ItemServiceTests: XCTestCase {

    var sut: ItemService!
    var avatar: Avatar!

    override func setUp() {
        super.setUp()
        sut = ItemService()
        avatar = Avatar(name: "TestHero", level: 10)
    }

    override func tearDown() {
        sut = nil
        avatar = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createTestItem(slot: EquipmentSlot, levelRequirement: Int = 1) -> Item {
        let template = ItemTemplate(
            templateId: "test_\(slot.rawValue)_001",
            name: "Test \(slot.rawValue)",
            description: "Test item",
            slot: slot,
            rarity: .rare,
            levelRequirement: levelRequirement,
            baseStats: Stats()
        )

        let mainAffix = Affix(type: .attack, value: 100, isPercentage: false)
        let subAffixes = [
            Affix(type: .crit, value: 5, isPercentage: true),
            Affix(type: .defense, value: 50, isPercentage: false)
        ]

        return Item(template: template, mainAffix: mainAffix, subAffixes: subAffixes)
    }

    // MARK: - T029: testEquipItemWhenSlotMatchesThenItemEquipped

    func testEquipItemWhenSlotMatchesThenItemEquipped() {
        // Given
        let item = createTestItem(slot: .helmet)
        avatar.inventory.add(item)

        // When
        let result = sut.equip(item, to: .helmet, avatar: avatar)

        // Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(avatar.equipment.getItem(at: .helmet))
        XCTAssertEqual(avatar.equipment.getItem(at: .helmet)?.instanceId, item.instanceId)
        XCTAssertFalse(avatar.inventory.contains(item))
    }

    // MARK: - T030: testEquipItemWhenSlotMismatchThenReturnsFailure

    func testEquipItemWhenSlotMismatchThenReturnsFailure() {
        // Given
        let helmetItem = createTestItem(slot: .helmet)
        avatar.inventory.add(helmetItem)

        // When
        let result = sut.equip(helmetItem, to: .boots, avatar: avatar)

        // Then
        XCTAssertEqual(result, .slotMismatch)
        XCTAssertNil(avatar.equipment.getItem(at: .boots))
        XCTAssertTrue(avatar.inventory.contains(helmetItem))
    }

    // MARK: - T031: testEquipItemWhenLevelTooLowThenReturnsFailure

    func testEquipItemWhenLevelTooLowThenReturnsFailure() {
        // Given
        let highLevelItem = createTestItem(slot: .helmet, levelRequirement: 50)
        avatar.inventory.add(highLevelItem)

        // When
        let result = sut.equip(highLevelItem, to: .helmet, avatar: avatar)

        // Then
        XCTAssertEqual(result, .levelTooLow(required: 50, current: 10))
        XCTAssertNil(avatar.equipment.getItem(at: .helmet))
        XCTAssertTrue(avatar.inventory.contains(highLevelItem))
    }

    // MARK: - T032: testEquipItemWhenSlotOccupiedThenSwapsItems

    func testEquipItemWhenSlotOccupiedThenSwapsItems() {
        // Given
        let oldHelmet = createTestItem(slot: .helmet)
        let newHelmet = createTestItem(slot: .helmet)
        avatar.inventory.add(oldHelmet)
        _ = sut.equip(oldHelmet, to: .helmet, avatar: avatar)
        avatar.inventory.add(newHelmet)

        // When
        let result = sut.equip(newHelmet, to: .helmet, avatar: avatar)

        // Then
        XCTAssertTrue(result.isSuccess)
        if case .success(let replacedItem) = result {
            XCTAssertEqual(replacedItem?.instanceId, oldHelmet.instanceId)
        }
        XCTAssertEqual(avatar.equipment.getItem(at: .helmet)?.instanceId, newHelmet.instanceId)
        XCTAssertTrue(avatar.inventory.contains(oldHelmet))
        XCTAssertFalse(avatar.inventory.contains(newHelmet))
    }

    // MARK: - T033: testUnequipItemWhenInventoryFullThenReturnsFailure

    func testUnequipItemWhenInventoryFullThenReturnsFailure() {
        // Given
        let smallInventoryAvatar = Avatar(name: "SmallBag", level: 10, inventoryCapacity: 1)
        let helmet = createTestItem(slot: .helmet)
        let anotherItem = createTestItem(slot: .boots)

        smallInventoryAvatar.inventory.add(helmet)
        _ = sut.equip(helmet, to: .helmet, avatar: smallInventoryAvatar)
        smallInventoryAvatar.inventory.add(anotherItem) // 填滿背包

        // When
        let result = sut.unequip(slot: .helmet, avatar: smallInventoryAvatar)

        // Then
        XCTAssertEqual(result, .inventoryFull)
        XCTAssertNotNil(smallInventoryAvatar.equipment.getItem(at: .helmet))
    }

    // MARK: - Additional Tests

    func testUnequipItemWhenSlotEmptyThenReturnsSlotEmpty() {
        // Given - 空的裝備欄位

        // When
        let result = sut.unequip(slot: .helmet, avatar: avatar)

        // Then
        XCTAssertEqual(result, .slotEmpty)
    }

    func testEquipItemWhenItemNotInInventoryThenReturnsFailure() {
        // Given
        let item = createTestItem(slot: .helmet)
        // 不加入背包

        // When
        let result = sut.equip(item, to: .helmet, avatar: avatar)

        // Then
        XCTAssertEqual(result, .itemNotInInventory)
    }
}
