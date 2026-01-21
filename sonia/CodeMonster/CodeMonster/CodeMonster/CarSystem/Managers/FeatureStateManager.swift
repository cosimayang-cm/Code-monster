import Foundation

/// 管理功能狀態與連鎖停用邏輯
class FeatureStateManager {
    
    // MARK: - Properties
    private var enabledFeatures: Set<Feature> = []
    private var featureComponents: [Feature: FeatureToggleComponent] = [:]
    private let validator: DependencyValidating
    
    // MARK: - Initialization
    init(configuration: CarConfiguration,
         validator: DependencyValidating = DependencyValidator()) {
        self.validator = validator
        
        // 根據配置安裝元件
        configuration.features.forEach { feature in
            featureComponents[feature] = ComponentFactory.create(feature)
        }
    }
    
    // MARK: - Feature Toggle
    func enable(_ feature: Feature,
                centralComputerOn: Bool,
                engineRunning: Bool) -> Result<Void, FeatureError> {
        // 檢查是否已安裝
        guard featureComponents[feature] != nil else {
            return .failure(.featureNotInstalled)
        }
        
        // 檢查是否已啟用
        guard !enabledFeatures.contains(feature) else {
            return .success(())
        }
        
        // 驗證依賴
        let result = validator.validateEnable(
            feature: feature,
            centralComputerOn: centralComputerOn,
            engineRunning: engineRunning,
            enabledFeatures: enabledFeatures
        )
        
        guard result.isSuccess else {
            return result
        }
        
        // 啟用功能
        featureComponents[feature]?.isEnabled = true
        enabledFeatures.insert(feature)
        return .success(())
    }
    
    func disable(_ feature: Feature) -> Result<[Feature], FeatureError> {
        guard featureComponents[feature] != nil else {
            return .failure(.featureNotInstalled)
        }
        
        guard enabledFeatures.contains(feature) else {
            return .success([])
        }
        
        let disabled = disableRecursive(feature)
        return .success(disabled)
    }
    
    // MARK: - Recursive Disable Logic
    private func disableRecursive(_ feature: Feature) -> [Feature] {
        var disabledFeatures: [Feature] = []
        
        // 找出依賴此功能的其他功能
        let dependents = validator.getDependentFeatures(
            of: feature,
            from: enabledFeatures
        )
        
        // 遞迴停用每個依賴者
        for dependent in dependents {
            let cascadeDisabled = disableRecursive(dependent)
            disabledFeatures.append(contentsOf: cascadeDisabled)
        }
        
        // 停用自己
        if enabledFeatures.contains(feature) {
            featureComponents[feature]?.isEnabled = false
            enabledFeatures.remove(feature)
            disabledFeatures.append(feature)
        }
        
        return disabledFeatures
    }
    
    // MARK: - Query
    func isEnabled(_ feature: Feature) -> Bool {
        enabledFeatures.contains(feature)
    }
    
    func getEnabledFeatures() -> [Feature] {
        Array(enabledFeatures).sorted { $0.displayName < $1.displayName }
    }
    
    func isAvailable(_ feature: Feature,
                     centralComputerOn: Bool,
                     engineRunning: Bool) -> Bool {
        validator.validateEnable(
            feature: feature,
            centralComputerOn: centralComputerOn,
            engineRunning: engineRunning,
            enabledFeatures: enabledFeatures
        ).isSuccess
    }
    
    func getInstalledFeatures() -> [Feature] {
        Array(featureComponents.keys).sorted { $0.displayName < $1.displayName }
    }
}
