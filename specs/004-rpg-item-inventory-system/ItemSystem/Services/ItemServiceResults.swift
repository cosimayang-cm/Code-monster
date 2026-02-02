import Foundation

/// 裝備操作結果
public enum EquipResult: Equatable {
    case success(replacedItem: Item?)
    case slotMismatch
    case levelTooLow(required: Int, current: Int)
    case itemNotInInventory

    public static func == (lhs: EquipResult, rhs: EquipResult) -> Bool {
        switch (lhs, rhs) {
        case (.success(let l), .success(let r)):
            return l?.instanceId == r?.instanceId
        case (.slotMismatch, .slotMismatch):
            return true
        case (.levelTooLow(let lr, let lc), .levelTooLow(let rr, let rc)):
            return lr == rr && lc == rc
        case (.itemNotInInventory, .itemNotInInventory):
            return true
        default:
            return false
        }
    }

    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

/// 卸下裝備結果
public enum UnequipResult: Equatable {
    case success(item: Item)
    case slotEmpty
    case inventoryFull

    public static func == (lhs: UnequipResult, rhs: UnequipResult) -> Bool {
        switch (lhs, rhs) {
        case (.success(let l), .success(let r)):
            return l.instanceId == r.instanceId
        case (.slotEmpty, .slotEmpty):
            return true
        case (.inventoryFull, .inventoryFull):
            return true
        default:
            return false
        }
    }

    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
