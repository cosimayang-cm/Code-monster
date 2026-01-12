import XCTest
@testable import FeatureToggleCar

// MARK: - Feature Toggle 測試

final class FeatureToggleTests: XCTestCase {

    func test_啟用功能_中控未開_應該失敗() {
        let car = Car()
        // 中控電腦預設是關閉的

        let result = car.enable(.airConditioner)

        XCTAssertEqual(result, .failure(.computerOff))
    }

    func test_啟用功能_缺少相依_應該失敗() {
        let car = Car()
        car.turnOnComputer()

        // AutoPilot 需要很多相依功能
        let result = car.enable(.autoPilot)

        if case .failure(.missingDependencies(let missing)) = result {
            XCTAssertFalse(missing.isEmpty)
        } else {
            XCTFail("應該回傳 missingDependencies 錯誤")
        }
    }

    func test_啟用功能_滿足相依_應該成功() {
        let car = Car()
        car.turnOnComputer()

        let result = car.enable(.airConditioner)

        XCTAssertEqual(result, .success(()))
        XCTAssertTrue(car.isEnabled(.airConditioner))
    }

    func test_啟用功能_需要引擎_引擎未開_應該失敗() {
        let car = Car()
        car.turnOnComputer()
        car.enable(.navigation)
        car.enable(.frontRadar)

        // laneKeeping 需要引擎運行
        let result = car.enable(.laneKeeping)

        XCTAssertEqual(result, .failure(.engineNotRunning))
    }

    func test_完整啟用AutoPilot流程() {
        let car = Car()
        car.turnOnComputer()
        car.startEngine()

        // 按相依順序啟用
        XCTAssertEqual(car.enable(.rearCamera), .success(()))
        XCTAssertEqual(car.enable(.surroundView), .success(()))
        XCTAssertEqual(car.enable(.navigation), .success(()))
        XCTAssertEqual(car.enable(.frontRadar), .success(()))
        XCTAssertEqual(car.enable(.laneKeeping), .success(()))
        XCTAssertEqual(car.enable(.emergencyBraking), .success(()))
        XCTAssertEqual(car.enable(.autoPilot), .success(()))

        XCTAssertTrue(car.isEnabled(.autoPilot))
    }
}

// MARK: - 連鎖停用測試

final class CascadeDisableTests: XCTestCase {

    func test_停用功能_應該連鎖停用依賴者() {
        let car = Car()
        car.turnOnComputer()
        car.startEngine()
        car.enable(.rearCamera)
        car.enable(.surroundView)
        car.enable(.navigation)
        car.enable(.frontRadar)
        car.enable(.laneKeeping)
        car.enable(.emergencyBraking)
        car.enable(.autoPilot)

        // 停用 navigation
        car.disable(.navigation)

        // laneKeeping 和 autoPilot 應該被連鎖停用
        XCTAssertFalse(car.isEnabled(.navigation))
        XCTAssertFalse(car.isEnabled(.laneKeeping))
        XCTAssertFalse(car.isEnabled(.autoPilot))

        // 但 emergencyBraking 和 surroundView 不應該被影響
        XCTAssertTrue(car.isEnabled(.emergencyBraking))
        XCTAssertTrue(car.isEnabled(.surroundView))
    }

    func test_關閉中控_應該停用所有功能() {
        let car = Car()
        car.turnOnComputer()
        car.enable(.airConditioner)
        car.enable(.navigation)
        car.enable(.bluetooth)

        car.turnOffComputer()

        XCTAssertTrue(car.getEnabledFeatures().isEmpty)
    }

    func test_停止引擎_應該停用需要引擎的功能() {
        let car = Car()
        car.turnOnComputer()
        car.startEngine()
        car.enable(.navigation)
        car.enable(.frontRadar)
        car.enable(.laneKeeping)
        car.enable(.airConditioner)

        car.stopEngine()

        XCTAssertFalse(car.isEnabled(.laneKeeping))
        XCTAssertTrue(car.isEnabled(.airConditioner))  // 不需要引擎
        XCTAssertTrue(car.isEnabled(.navigation))      // 不需要引擎
    }
}

// MARK: - Builder 測試

final class CarBuilderTests: XCTestCase {

    func test_Builder_FluentAPI() {
        let car = CarBuilder()
            .withNavigation()
            .withBluetooth()
            .withSurroundView()
            .build()

        XCTAssertTrue(car.isEnabled(.navigation))
        XCTAssertTrue(car.isEnabled(.bluetooth))
        XCTAssertTrue(car.isEnabled(.surroundView))
        XCTAssertTrue(car.isEnabled(.rearCamera))  // 自動包含
    }

    func test_Builder_withAutoPilot_應該啟用所有相依() {
        let car = CarBuilder()
            .withAutoPilot()
            .build()

        XCTAssertTrue(car.isEnabled(.autoPilot))
        XCTAssertTrue(car.isEnabled(.laneKeeping))
        XCTAssertTrue(car.isEnabled(.emergencyBraking))
        XCTAssertTrue(car.isEnabled(.surroundView))
        XCTAssertTrue(car.isEngineRunning)
    }
}

// MARK: - Factory 測試

final class CarFactoryTests: XCTestCase {

    func test_Factory_Basic() {
        let car = CarFactory.create(.basic)

        XCTAssertTrue(car.getEnabledFeatures().isEmpty)
        XCTAssertTrue(car.isComputerOn)
    }

    func test_Factory_Standard() {
        let car = CarFactory.create(.standard)

        XCTAssertTrue(car.isEnabled(.airConditioner))
        XCTAssertTrue(car.isEnabled(.entertainment))
        XCTAssertTrue(car.isEnabled(.bluetooth))
        XCTAssertFalse(car.isEnabled(.navigation))
    }

    func test_Factory_Autonomous() {
        let car = CarFactory.create(.autonomous)

        XCTAssertTrue(car.isEnabled(.autoPilot))
        XCTAssertTrue(car.isEngineRunning)
    }

    func test_Factory_批量生產() {
        let cars = CarFactory.createBatch(.premium, count: 3)

        XCTAssertEqual(cars.count, 3)
        cars.forEach { car in
            XCTAssertTrue(car.isEnabled(.navigation))
            XCTAssertTrue(car.isEnabled(.surroundView))
        }
    }
}
