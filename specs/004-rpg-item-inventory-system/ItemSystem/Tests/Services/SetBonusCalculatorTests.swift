import XCTest
@testable import ItemSystem

final class SetBonusCalculatorTests: XCTestCase {

    var sut: SetBonusCalculator!

    override func setUp() {
        super.setUp()
        sut = SetBonusCalculator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createTestSet() -> EquipmentSet {
        return EquipmentSet(
            setId: "noblesse_oblige",
            name: "昔日宗室之儀",
            pieces: ["noblesse_helmet", "noblesse_body", "noblesse_gloves", "noblesse_boots", "noblesse_belt"],
            bonuses: [
                SetBonus(
                    requiredPieces: 2,
                    effect: .statBonus(stat: .attack, value: 20, isPercentage: true),
                    description: "攻擊力 +20%"
                ),
                SetBonus(
                    requiredPieces: 4,
                    effect: .statBonus(stat: .critRate, value: 15, isPercentage: false),
                    description: "暴擊率 +15%"
                )
            ]
        )
    }

    private func createTestItem(slot: EquipmentSlot, setId: String?) -> Item {
        let template = ItemTemplate(
            templateId: setId != nil ? "\(setId!)_\(slot.rawValue)" : "generic_\(slot.rawValue)",
            name: "Test \(slot.rawValue)",
            description: "Test",
            slot: slot,
            rarity: .legendary,
            levelRequirement: 1,
            baseStats: Stats(),
            setId: setId
        )
        return Item(
            template: template,
            mainAffix: Affix(type: .attack, value: 100, isPercentage: false),
            subAffixes: []
        )
    }

    // MARK: - T063: testCalculateSetBonusesWhenTwoPiecesThenTriggersTwoPieceBonus

    func testCalculateSetBonusesWhenTwoPiecesThenTriggersTwoPieceBonus() {
        // Given
        let avatar = Avatar(name: "TestHero", level: 10)
        let testSet = createTestSet()

        let helmet = createTestItem(slot: .helmet, setId: "noblesse_oblige")
        let body = createTestItem(slot: .body, setId: "noblesse_oblige")

        _ = avatar.equipment.equip(helmet)
        _ = avatar.equipment.equip(body)

        // When
        let bonuses = sut.calculateSetBonuses(for: avatar, sets: [testSet])

        // Then
        XCTAssertEqual(bonuses.count, 1)
        XCTAssertEqual(bonuses.first?.bonus.requiredPieces, 2)
        XCTAssertEqual(bonuses.first?.equippedCount, 2)
    }

    // MARK: - T064: testCalculateSetBonusesWhenFourPiecesThenTriggersBothBonuses

    func testCalculateSetBonusesWhenFourPiecesThenTriggersBothBonuses() {
        // Given
        let avatar = Avatar(name: "TestHero", level: 10)
        let testSet = createTestSet()

        _ = avatar.equipment.equip(createTestItem(slot: .helmet, setId: "noblesse_oblige"))
        _ = avatar.equipment.equip(createTestItem(slot: .body, setId: "noblesse_oblige"))
        _ = avatar.equipment.equip(createTestItem(slot: .gloves, setId: "noblesse_oblige"))
        _ = avatar.equipment.equip(createTestItem(slot: .boots, setId: "noblesse_oblige"))

        // When
        let bonuses = sut.calculateSetBonuses(for: avatar, sets: [testSet])

        // Then
        XCTAssertEqual(bonuses.count, 2)
        XCTAssertTrue(bonuses.contains { $0.bonus.requiredPieces == 2 })
        XCTAssertTrue(bonuses.contains { $0.bonus.requiredPieces == 4 })
    }

    // MARK: - T065: testCalculateSetBonusesWhenMixedSetsThenTriggersMultipleBonuses

    func testCalculateSetBonusesWhenMixedSetsThenTriggersMultipleBonuses() {
        // Given
        let avatar = Avatar(name: "TestHero", level: 10)

        let setA = EquipmentSet(
            setId: "set_a",
            name: "套裝 A",
            pieces: ["set_a_helmet", "set_a_body"],
            bonuses: [SetBonus(requiredPieces: 2, effect: .statBonus(stat: .attack, value: 10, isPercentage: true), description: "攻擊 +10%")]
        )
        let setB = EquipmentSet(
            setId: "set_b",
            name: "套裝 B",
            pieces: ["set_b_gloves", "set_b_boots"],
            bonuses: [SetBonus(requiredPieces: 2, effect: .statBonus(stat: .defense, value: 15, isPercentage: true), description: "防禦 +15%")]
        )

        _ = avatar.equipment.equip(createTestItem(slot: .helmet, setId: "set_a"))
        _ = avatar.equipment.equip(createTestItem(slot: .body, setId: "set_a"))
        _ = avatar.equipment.equip(createTestItem(slot: .gloves, setId: "set_b"))
        _ = avatar.equipment.equip(createTestItem(slot: .boots, setId: "set_b"))

        // When
        let bonuses = sut.calculateSetBonuses(for: avatar, sets: [setA, setB])

        // Then
        XCTAssertEqual(bonuses.count, 2)
        XCTAssertTrue(bonuses.contains { $0.set.setId == "set_a" })
        XCTAssertTrue(bonuses.contains { $0.set.setId == "set_b" })
    }

    // MARK: - T066: testCalculateSetBonusesWhenThreePiecesThenTriggersTwoPieceBonusOnly

    func testCalculateSetBonusesWhenThreePiecesThenTriggersTwoPieceBonusOnly() {
        // Given
        let avatar = Avatar(name: "TestHero", level: 10)
        let testSet = createTestSet()

        _ = avatar.equipment.equip(createTestItem(slot: .helmet, setId: "noblesse_oblige"))
        _ = avatar.equipment.equip(createTestItem(slot: .body, setId: "noblesse_oblige"))
        _ = avatar.equipment.equip(createTestItem(slot: .gloves, setId: "noblesse_oblige"))

        // When
        let bonuses = sut.calculateSetBonuses(for: avatar, sets: [testSet])

        // Then
        XCTAssertEqual(bonuses.count, 1)
        XCTAssertEqual(bonuses.first?.bonus.requiredPieces, 2)
        XCTAssertEqual(bonuses.first?.equippedCount, 3)
    }

    // MARK: - Additional Tests

    func testCalculateSetBonusesWhenOnePieceThenNoBonus() {
        // Given
        let avatar = Avatar(name: "TestHero", level: 10)
        let testSet = createTestSet()

        _ = avatar.equipment.equip(createTestItem(slot: .helmet, setId: "noblesse_oblige"))

        // When
        let bonuses = sut.calculateSetBonuses(for: avatar, sets: [testSet])

        // Then
        XCTAssertEqual(bonuses.count, 0)
    }
}
