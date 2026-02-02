import Foundation

/// 數值計算協議
public protocol StatsCalculating {
    /// 計算角色總數值（基礎 + 裝備加成）
    func calculateTotalStats(for avatar: Avatar) -> Stats

    /// 計算單件裝備的數值貢獻
    func calculateItemStats(_ item: Item) -> Stats

    /// 計算主詞條數值（含等級成長）
    func calculateMainAffixValue(affix: Affix, level: Int) -> Double
}
