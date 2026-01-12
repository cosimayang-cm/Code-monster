/// 功能操作錯誤
enum FeatureError: Error, Equatable {
    case computerOff                         // 中控電腦未開啟
    case engineNotRunning                    // 引擎未運行
    case missingDependencies([Feature])      // 缺少前置功能

    var description: String {
        switch self {
        case .computerOff:
            return "中控電腦未開啟"
        case .engineNotRunning:
            return "引擎未運行"
        case .missingDependencies(let features):
            let names = features.map { $0.displayName }.joined(separator: ", ")
            return "缺少前置功能: \(names)"
        }
    }
}
