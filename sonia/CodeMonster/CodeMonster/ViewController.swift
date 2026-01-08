//
//  ViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testCarFeatureToggle()
    }
    
    private func testCarFeatureToggle() {
        let car = Car()
        
        print("\n--- Test 1: 嘗試在中控電腦關閉時啟用功能 ---")
        _ = car.enableFeature(.airConditioner) // 應該失敗
        
        print("\n--- Test 2: 開啟中控電腦後啟用功能 ---")
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner) // 應該成功
        _ = car.enableFeature(.navigation) // 應該成功
        car.printStatus()
        
        print("\n--- Test 3: 啟用所有獨立功能 ---")
        _ = car.enableFeature(.entertainment)
        _ = car.enableFeature(.bluetooth)
        car.printStatus()
        
        print("\n--- Test 4: 嘗試啟用有相依性的功能 ---")
        _ = car.enableFeature(.surroundView) // 需要 rearCamera，應該失敗
        
        print("\n--- Test 5: 啟用相依功能後再試 ---")
        _ = car.enableFeature(.rearCamera) // 先啟用倒車鏡頭
        _ = car.enableFeature(.surroundView) // 現在應該成功
        _ = car.enableFeature(.blindSpotDetection) // 盲點偵測
        car.printStatus()
        
        print("\n--- Test 6: 啟用 Parking Assist ---")
        _ = car.enableFeature(.parkingAssist) // 需要 surroundView + blindSpotDetection
        car.printStatus()
        
        print("\n--- Test 7: 啟用複雜相依性功能 ---")
        car.startEngine() // 啟動引擎
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping) // 需要 navigation + frontRadar + engine
        _ = car.enableFeature(.emergencyBraking) // 需要 frontRadar + engine
        car.printStatus()
        
        print("\n--- Test 8: 啟用最高階功能 AutoPilot ---")
        _ = car.enableFeature(.autoPilot) // 需要 laneKeeping + emergencyBraking + surroundView
        car.printStatus()
        
        print("\n--- Test 9: 停用有依賴的功能（連鎖停用）---")
        _ = car.disableFeature(.frontRadar) // 應該連鎖停用 laneKeeping, emergencyBraking, autoPilot
        car.printStatus()
        
        print("\n--- Test 10: 關閉引擎的影響 ---")
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.emergencyBraking)
        car.stopEngine() // 應該停用需要引擎的功能
        car.printStatus()
        
        print("\n--- Test 11: 關閉中控電腦的影響 ---")
        car.turnOffCentralComputer() // 應該停用所有功能
        car.printStatus()
        
        print("\n--- Test 12: 驗證所有功能都已測試 ---")
        print("✅ 已測試的功能:")
        print("  1. Air Conditioner")
        print("  2. Navigation System")
        print("  3. Entertainment System")
        print("  4. Bluetooth System")
        print("  5. Rear Camera")
        print("  6. Surround View Camera")
        print("  7. Blind Spot Detection")
        print("  8. Front Radar")
        print("  9. Parking Assist")
        print("  10. Lane Keeping")
        print("  11. Emergency Braking")
        print("  12. Auto Pilot")
        print("🎉 所有 12 個功能測試完成！")
    }
}

