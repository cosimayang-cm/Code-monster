import Foundation

/// 背包（物品容器，有容量限制）
public class Inventory: Codable {
    private var items: [Item] = []
    public let capacity: Int

    public init(capacity: Int = 50) {
        self.capacity = capacity
    }

    /// 物品數量
    public var count: Int { items.count }

    /// 是否已滿
    public var isFull: Bool { count >= capacity }

    /// 剩餘空間
    public var availableSpace: Int { capacity - count }

    /// 新增物品
    @discardableResult
    public func add(_ item: Item) -> Bool {
        guard !isFull else { return false }
        items.append(item)
        return true
    }

    /// 移除物品
    @discardableResult
    public func remove(_ item: Item) -> Bool {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            return true
        }
        return false
    }

    /// 取得物品（by instanceId）
    public func getItem(byId id: UUID) -> Item? {
        items.first { $0.instanceId == id }
    }

    /// 取得所有物品
    public var allItems: [Item] {
        items
    }

    /// 依詞條篩選物品
    public func filter(byAffixMask mask: AffixType, matchAll: Bool = true) -> [Item] {
        items.filter { item in
            if matchAll {
                return item.affixMask.contains(mask)
            } else {
                return !item.affixMask.isDisjoint(with: mask)
            }
        }
    }

    /// 檢查是否包含物品
    public func contains(_ item: Item) -> Bool {
        items.contains(item)
    }
}
