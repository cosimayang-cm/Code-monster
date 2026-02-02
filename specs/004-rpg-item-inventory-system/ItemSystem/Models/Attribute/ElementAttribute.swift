import Foundation

/// 元素附加屬性
public struct ElementAttribute: Attribute, Equatable {
    public let attributeType: String = "element"
    public let element: Element
    public let value: Double

    public init(element: Element, value: Double) {
        self.element = element
        self.value = value
    }

    /// 元素屬性目前不直接影響基礎數值
    /// 實際效果需在戰鬥系統中處理
    public func apply(to stats: inout Stats) {
        // 元素傷害加成需要戰鬥系統計算
        // 這裡保留空實作
    }
}
