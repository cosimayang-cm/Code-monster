import Foundation

/// Canvas Protocol - 畫布介面定義
///
/// 定義畫布的基本操作，用於解耦 Commands 和具體實作。
/// 遵循 PAGEs Framework 的 Protocol 抽象原則。
///
/// Design rationale:
/// - Protocol-oriented design 提升可測試性
/// - Commands 透過 weak reference 持有 CanvasProtocol，避免 retain cycle
/// - Foundation-only，不依賴 UIKit
public protocol CanvasProtocol: AnyObject {
    /// 畫布上的所有圖形
    var shapes: [Shape] { get }

    /// 目前選取的圖形 ID
    var selectedShapeId: UUID? { get set }

    /// 新增圖形到畫布
    ///
    /// - Parameter shape: 要新增的圖形
    func add(shape: Shape)

    /// 從畫布移除圖形
    ///
    /// - Parameter shape: 要移除的圖形
    /// - Returns: 圖形在陣列中的索引（供 undo 使用），nil 表示圖形不存在
    @discardableResult
    func remove(shape: Shape) -> Int?

    /// 移動圖形
    ///
    /// - Parameters:
    ///   - shape: 要移動的圖形
    ///   - offset: 位移量
    func move(shape: Shape, by offset: Point)

    /// 縮放圖形
    ///
    /// - Parameters:
    ///   - shape: 要縮放的圖形
    ///   - size: 新的大小
    func resize(shape: Shape, to size: Size)

    /// 變更圖形顏色
    ///
    /// - Parameters:
    ///   - shape: 要變更的圖形
    ///   - fillColor: 填充顏色（nil 表示不變更，Optional.some(nil) 表示清除填充）
    ///   - strokeColor: 邊框顏色（nil 表示不變更，Optional.some(nil) 表示清除邊框）
    func changeColor(
        shape: Shape,
        fillColor: Color??,
        strokeColor: Color??
    )

    /// 根據 ID 尋找圖形
    ///
    /// - Parameter id: 圖形 ID
    /// - Returns: 找到的圖形，不存在則為 nil
    func findShape(by id: UUID) -> Shape?
}
