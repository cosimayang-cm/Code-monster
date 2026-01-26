import Foundation

/// Canvas - 畫布編輯器的接收者 (Receiver)
/// FR-017: Canvas as Receiver, manages all shape objects
final class Canvas {

    // MARK: - Properties

    /// 畫布上的所有圖形
    private(set) var shapes: [any Shape] = []

    // MARK: - Initialization

    init() {}

    // MARK: - Shape Management

    /// 新增圖形到畫布
    /// - Parameter shape: 要新增的圖形
    func add(_ shape: any Shape) {
        shapes.append(shape)
    }

    /// 移除指定 ID 的圖形
    /// - Parameter id: 圖形的 UUID
    /// - Returns: 被移除的圖形，若不存在則回傳 nil
    @discardableResult
    func remove(id: UUID) -> (any Shape)? {
        guard let index = shapes.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return shapes.remove(at: index)
    }

    /// 取得指定 ID 的圖形
    /// - Parameter id: 圖形的 UUID
    /// - Returns: 對應的圖形，若不存在則回傳 nil
    func shape(withId id: UUID) -> (any Shape)? {
        return shapes.first(where: { $0.id == id })
    }

    /// 取得指定 ID 圖形的索引
    /// - Parameter id: 圖形的 UUID
    /// - Returns: 索引，若不存在則回傳 nil
    func index(of id: UUID) -> Int? {
        return shapes.firstIndex(where: { $0.id == id })
    }

    /// 更新指定 ID 的圖形
    /// - Parameters:
    ///   - id: 圖形的 UUID
    ///   - newShape: 更新後的圖形
    func updateShape(id: UUID, with newShape: any Shape) {
        guard let index = shapes.firstIndex(where: { $0.id == id }) else {
            return
        }
        shapes[index] = newShape
    }

    /// 在指定索引插入圖形
    /// - Parameters:
    ///   - shape: 要插入的圖形
    ///   - index: 插入位置
    func insert(_ shape: any Shape, at index: Int) {
        shapes.insert(shape, at: index)
    }
}
