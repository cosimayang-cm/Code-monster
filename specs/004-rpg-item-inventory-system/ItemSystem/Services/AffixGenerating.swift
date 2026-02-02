import Foundation

/// 詞條生成協議
public protocol AffixGenerating {
    /// 生成主詞條
    /// - Parameter pool: 主詞條池
    /// - Returns: 生成的主詞條
    func generateMainAffix(from pool: [WeightedAffix]) -> Affix?

    /// 生成副詞條
    /// - Parameters:
    ///   - pool: 副詞條池
    ///   - count: 要生成的數量
    ///   - excluding: 排除的詞條類型（避免與主詞條重複）
    /// - Returns: 生成的副詞條陣列
    func generateSubAffixes(from pool: [WeightedAffix], count: Int, excluding: AffixType) -> [Affix]
}
