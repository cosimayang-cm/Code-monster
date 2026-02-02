import Foundation

/// 詞條生成服務（權重隨機選擇）
public class AffixGenerator: AffixGenerating {

    public init() {}

    public func generateMainAffix(from pool: [WeightedAffix]) -> Affix? {
        guard !pool.isEmpty else { return nil }

        let weightedAffix = selectWeighted(from: pool)
        return createAffix(from: weightedAffix)
    }

    public func generateSubAffixes(from pool: [WeightedAffix], count: Int, excluding: AffixType) -> [Affix] {
        guard count > 0 else { return [] }

        // 過濾掉排除的類型
        let filteredPool = pool.filter { !excluding.contains($0.type) }
        guard !filteredPool.isEmpty else { return [] }

        var generatedAffixes: [Affix] = []
        var usedTypes: AffixType = []

        while generatedAffixes.count < count {
            // 從剩餘的池中選擇
            let availablePool = filteredPool.filter { !usedTypes.contains($0.type) }
            guard !availablePool.isEmpty else { break }

            let weightedAffix = selectWeighted(from: availablePool)
            let affix = createAffix(from: weightedAffix)

            generatedAffixes.append(affix)
            usedTypes.insert(affix.type)
        }

        return generatedAffixes
    }

    // MARK: - Private Helpers

    /// 根據權重隨機選擇詞條
    private func selectWeighted(from pool: [WeightedAffix]) -> WeightedAffix {
        let totalWeight = pool.reduce(0) { $0 + $1.weight }
        var random = Int.random(in: 0..<totalWeight)

        for weightedAffix in pool {
            random -= weightedAffix.weight
            if random < 0 {
                return weightedAffix
            }
        }

        return pool.last! // Fallback
    }

    /// 從 WeightedAffix 創建 Affix（隨機數值）
    private func createAffix(from weightedAffix: WeightedAffix) -> Affix {
        let value = Double.random(in: weightedAffix.minValue...weightedAffix.maxValue)
        return Affix(
            type: weightedAffix.type,
            value: value,
            isPercentage: weightedAffix.isPercentage
        )
    }
}
