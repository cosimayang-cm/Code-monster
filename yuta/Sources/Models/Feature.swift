/// 12 個可 Toggle 的功能
enum Feature: String, CaseIterable {
    case airConditioner      = "空調系統"
    case navigation          = "導航系統"
    case entertainment       = "娛樂系統"
    case bluetooth           = "藍牙系統"
    case rearCamera          = "倒車鏡頭"
    case surroundView        = "環景攝影"
    case blindSpotDetection  = "盲點偵測"
    case frontRadar          = "前方雷達"
    case parkingAssist       = "停車輔助"
    case laneKeeping         = "車道維持"
    case emergencyBraking    = "緊急煞車"
    case autoPilot           = "自動駕駛"

    /// 此功能需要哪些前置功能（相依性宣告）
    var requiredFeatures: [Feature] {
        switch self {
        case .surroundView:     return [.rearCamera]
        case .parkingAssist:    return [.surroundView, .blindSpotDetection]
        case .laneKeeping:      return [.navigation, .frontRadar]
        case .emergencyBraking: return [.frontRadar]
        case .autoPilot:        return [.laneKeeping, .emergencyBraking, .surroundView]
        default:                return []
        }
    }

    /// 是否需要引擎運行中
    var requiresEngineRunning: Bool {
        switch self {
        case .laneKeeping, .emergencyBraking:
            return true
        default:
            return false
        }
    }

    /// 顯示名稱
    var displayName: String { rawValue }
}
