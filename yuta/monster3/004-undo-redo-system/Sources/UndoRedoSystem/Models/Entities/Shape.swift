import Foundation

/// Shape protocol - 圖形基礎 Protocol
///
/// 定義所有圖形共有的屬性和行為。
/// 使用 Foundation-only 型別（Point, Color），確保 Model 層不依賴 UIKit。
///
/// Design rationale:
/// - Protocol-oriented design 提供抽象層
/// - 使用 AnyObject 限制為 reference type
/// - 支援 deep copy 以實作 Memento Pattern
public protocol Shape: AnyObject {
    /// 唯一識別碼
    var id: UUID { get }

    /// 位置（對 Rectangle/Circle 為左上角/圓心，對 Line 為起點）
    var position: Point { get set }

    /// 填充顏色（nil 表示無填充）
    var fillColor: Color? { get set }

    /// 邊框顏色（nil 表示無邊框）
    var strokeColor: Color? { get set }

    /// 深拷貝
    ///
    /// 建立此圖形的完整複本，用於實作 Memento Pattern。
    /// 新圖形會有不同的 ID，但其他屬性相同。
    ///
    /// - Returns: 新的圖形實例
    func copy() -> Shape
}
