//
//  Car.swift
//  CarSystem
//
//  Created by Claude on 2026/1/11.
//
import Foundation

// MARK: - CarComponent Protocol
protocol CarComponent {
    var name: String { get }
    var isRequired: Bool { get }
}

// MARK: - Feature 列舉
enum Feature: String, CaseIterable {
    case airConditioner = "airConditioner"
    case navigation = "navigation"
    case entertainment = "entertainment"
    case bluetooth = "bluetooth"
    case rearCamera = "rearCamera"
    case surroundView = "surroundView"
    case blindSpotDetection = "blindSpotDetection"
    case frontRadar = "frontRadar"
    case parkingAssist = "parkingAssist"
    case laneKeeping = "laneKeeping"
    case emergencyBraking = "emergencyBraking"
    case autoPilot = "autoPilot"
    
    var displayName: String {
        switch self {
        case .airConditioner: return "🌡️ 空調系統"
        case .navigation: return "🗺️ 導航系統"
        case .entertainment: return "🎵 娛樂系統"
        case .bluetooth: return "📱 藍牙系統"
        case .rearCamera: return "📷 倒車鏡頭"
        case .surroundView: return "🔄 環景攝影"
        case .blindSpotDetection: return "👁️ 盲點偵測"
        case .frontRadar: return "📡 前方雷達"
        case .parkingAssist: return "🅿️ 停車輔助"
        case .laneKeeping: return "🛤️ 車道維持"
        case .emergencyBraking: return "🛑 緊急煞車"
        case .autoPilot: return "🤖 自動駕駛"
        }
    }
    
    var description: String {
        switch self {
        case .airConditioner: return "冷暖氣控制"
        case .navigation: return "GPS 導航"
        case .entertainment: return "音樂影片播放"
        case .bluetooth: return "藍牙連接裝置"
        case .rearCamera: return "倒車影像顯示"
        case .surroundView: return "360度環景影像"
        case .blindSpotDetection: return "偵測兩側盲點"
        case .frontRadar: return "前方障礙物偵測"
        case .parkingAssist: return "自動停車輔助"
        case .laneKeeping: return "自動維持車道"
        case .emergencyBraking: return "自動緊急煞車"
        case .autoPilot: return "全自動駕駛模式"
        }
    }
    
    /// 取得此功能的相依功能
    var dependencies: [Feature] {
        switch self {
        case .airConditioner, .navigation, .entertainment, .bluetooth, .rearCamera, .blindSpotDetection, .frontRadar:
            return [] // 只依賴中控電腦
        case .surroundView:
            return [.rearCamera]
        case .parkingAssist:
            return [.surroundView, .blindSpotDetection]
        case .laneKeeping:
            return [.navigation, .frontRadar]
        case .emergencyBraking:
            return [.frontRadar]
        case .autoPilot:
            return [.laneKeeping, .emergencyBraking, .surroundView]
        }
    }
    
    /// 是否需要中控電腦
    var requiresCentralComputer: Bool {
        return true // 所有功能都需要中控電腦
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
}

// MARK: - FeatureError 錯誤類型
enum FeatureError: Error, LocalizedError {
    case centralComputerOff
    case engineNotRunning
    case dependencyNotEnabled(Feature)
    case featureHasDependents([Feature])
    case featureAlreadyEnabled
    case featureAlreadyDisabled
    
    var errorDescription: String? {
        switch self {
        case .centralComputerOff:
            return "中控電腦未開啟"
        case .engineNotRunning:
            return "引擎未運行"
        case .dependencyNotEnabled(let feature):
            return "相依功能 \(feature.displayName) 未啟用"
        case .featureHasDependents(let features):
            let names = features.map { $0.displayName }.joined(separator: ", ")
            return "以下功能依賴此功能: \(names)"
        case .featureAlreadyEnabled:
            return "功能已啟用"
        case .featureAlreadyDisabled:
            return "功能已停用"
        }
    }
}

// MARK: - 必要元件

class Wheel: CarComponent {
    let name = "車輪"
    let isRequired = true
}

class Engine: CarComponent {
    let name = "引擎"
    let isRequired = true
    private(set) var isRunning = false
    
    func start() {
        isRunning = true
        print("🔧 引擎已啟動")
    }
    
    func stop() {
        isRunning = false
        print("🔧 引擎已停止")
    }
}

class Battery: CarComponent {
    let name = "電池"
    let isRequired = true
}

class CentralComputer: CarComponent {
    let name = "中控電腦"
    let isRequired = true
    private(set) var isOn = false
    
    func turnOn() {
        isOn = true
        print("💻 中控電腦已開啟")
    }
    
    func turnOff() {
        isOn = false
        print("💻 中控電腦已關閉")
    }
}

// MARK: - 選配元件

class AirConditioner: CarComponent {
    let name = "空調系統"
    let isRequired = false
}

class NavigationSystem: CarComponent {
    let name = "導航系統"
    let isRequired = false
}

class EntertainmentSystem: CarComponent {
    let name = "娛樂系統"
    let isRequired = false
}

class BluetoothSystem: CarComponent {
    let name = "藍牙系統"
    let isRequired = false
}

class RearCamera: CarComponent {
    let name = "倒車鏡頭"
    let isRequired = false
}

class SurroundViewCamera: CarComponent {
    let name = "環景攝影"
    let isRequired = false
}

class BlindSpotDetection: CarComponent {
    let name = "盲點偵測"
    let isRequired = false
}

class FrontRadar: CarComponent {
    let name = "前方雷達"
    let isRequired = false
}

class ParkingAssist: CarComponent {
    let name = "停車輔助"
    let isRequired = false
}

class LaneKeeping: CarComponent {
    let name = "車道維持"
    let isRequired = false
}

class EmergencyBraking: CarComponent {
    let name = "緊急煞車"
    let isRequired = false
}

class AutoPilot: CarComponent {
    let name = "自動駕駛"
    let isRequired = false
}

// MARK: - Car 類別

class Car {
    // 必要元件
    let wheels: [Wheel]
    let engine: Engine
    let battery: Battery
    let centralComputer: CentralComputer
    
    // 選配元件
    let airConditioner: AirConditioner
    let navigationSystem: NavigationSystem
    let entertainmentSystem: EntertainmentSystem
    let bluetoothSystem: BluetoothSystem
    let rearCamera: RearCamera
    let surroundViewCamera: SurroundViewCamera
    let blindSpotDetection: BlindSpotDetection
    let frontRadar: FrontRadar
    let parkingAssist: ParkingAssist
    let laneKeeping: LaneKeeping
    let emergencyBraking: EmergencyBraking
    let autoPilot: AutoPilot
    
    // 已啟用的功能
    private var _enabledFeatures: Set<Feature> = []
    
    var enabledFeatures: [Feature] {
        return Array(_enabledFeatures).sorted { $0.rawValue < $1.rawValue }
    }
    
    init() {
        // 初始化必要元件
        self.wheels = [Wheel(), Wheel(), Wheel(), Wheel()]
        self.engine = Engine()
        self.battery = Battery()
        self.centralComputer = CentralComputer()
        
        // 初始化選配元件
        self.airConditioner = AirConditioner()
        self.navigationSystem = NavigationSystem()
        self.entertainmentSystem = EntertainmentSystem()
        self.bluetoothSystem = BluetoothSystem()
        self.rearCamera = RearCamera()
        self.surroundViewCamera = SurroundViewCamera()
        self.blindSpotDetection = BlindSpotDetection()
        self.frontRadar = FrontRadar()
        self.parkingAssist = ParkingAssist()
        self.laneKeeping = LaneKeeping()
        self.emergencyBraking = EmergencyBraking()
        self.autoPilot = AutoPilot()
        
        print("🚗 車輛已建立，配備 \(wheels.count) 個車輪")
    }
    
    // MARK: - 功能管理
    
    /// 檢查功能是否已啟用
    func isFeatureEnabled(_ feature: Feature) -> Bool {
        return _enabledFeatures.contains(feature)
    }
    
    /// 啟用功能
    @discardableResult
    func enable(_ feature: Feature) -> Result<Void, FeatureError> {
        // 檢查是否已啟用
        if isFeatureEnabled(feature) {
            return .failure(.featureAlreadyEnabled)
        }
        
        // 檢查中控電腦
        if feature.requiresCentralComputer && !centralComputer.isOn {
            return .failure(.centralComputerOff)
        }
        
        // 檢查引擎
        if feature.requiresEngineRunning && !engine.isRunning {
            return .failure(.engineNotRunning)
        }
        
        // 檢查相依功能
        for dependency in feature.dependencies {
            if !isFeatureEnabled(dependency) {
                return .failure(.dependencyNotEnabled(dependency))
            }
        }
        
        // 啟用功能
        _enabledFeatures.insert(feature)
        print("✅ 已啟用: \(feature.displayName)")
        return .success(())
    }
    
    /// 停用功能（方案 B：連鎖停用依賴它的功能）
    @discardableResult
    func disable(_ feature: Feature) -> Result<Void, FeatureError> {
        // 檢查是否已停用
        if !isFeatureEnabled(feature) {
            return .failure(.featureAlreadyDisabled)
        }
        
        // 找出依賴此功能的其他功能並連鎖停用
        cascadeDisable(feature)
        
        return .success(())
    }
    
    /// 遞迴停用功能及其依賴者
    private func cascadeDisable(_ feature: Feature) {
        // 找出所有依賴此功能的功能
        let dependents = Feature.allCases.filter { 
            $0.dependencies.contains(feature) && isFeatureEnabled($0)
        }
        
        // 先遞迴停用依賴者
        for dependent in dependents {
            cascadeDisable(dependent)
        }
        
        // 停用此功能
        if _enabledFeatures.remove(feature) != nil {
            print("❌ 已停用: \(feature.displayName)")
        }
    }
    
    /// 取得依賴指定功能的所有功能
    func getDependents(of feature: Feature) -> [Feature] {
        return Feature.allCases.filter {
            $0.dependencies.contains(feature) && isFeatureEnabled($0)
        }
    }
    
    // MARK: - 中控電腦狀態整合
    
    /// 當中控電腦關閉時，停用所有依賴它的功能
    func onCentralComputerOff() {
        let featuresToDisable = _enabledFeatures.filter { $0.requiresCentralComputer }
        for feature in featuresToDisable {
            cascadeDisable(feature)
        }
    }
    
    // MARK: - 引擎狀態整合
    
    /// 當引擎停止時，停用需要引擎運行的功能
    func onEngineStop() {
        let featuresToDisable = _enabledFeatures.filter { $0.requiresEngineRunning }
        for feature in featuresToDisable {
            cascadeDisable(feature)
        }
    }
}

// MARK: - Car Extension for State Sync

extension Car {
    /// 同步中控電腦狀態
    func syncCentralComputerState() {
        if !centralComputer.isOn {
            onCentralComputerOff()
        }
    }
    
    /// 同步引擎狀態
    func syncEngineState() {
        if !engine.isRunning {
            onEngineStop()
        }
    }
}
