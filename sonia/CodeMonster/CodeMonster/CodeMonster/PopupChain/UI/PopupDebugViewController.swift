//
//  PopupDebugViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import UIKit

/// Debug UI for testing popup chain
class PopupDebugViewController: UIViewController {
    
    private var chainManager: PopupChainManager?
    private var repository: UserDefaultsPopupStateRepository!
    private var presenter: UIPopupPresenter!
    
    private var currentMemberId: String {
        switch userSegment.selectedSegmentIndex {
        case 0: return "new-user"
        case 1: return "experienced-user"
        default: return "new-user"
        }
    }
    
    // UI Elements
    private let startChainButton = UIButton(type: .system)
    private let changeUserButton = UIButton(type: .system)
    private let userInfoLabel = UILabel()
    private let stateLabel = UILabel()
    private let userSegment = UISegmentedControl(items: ["新用戶", "老用戶"])
    
    // State switches
    private let tutorialSwitch = UISwitch()
    private let adSwitch = UISwitch()
    private let newFeatureSwitch = UISwitch()
    private let dailyCheckInSwitch = UISwitch()
    private let predictionResultSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPopupSystem()
        updateStateDisplay()
        
        // Add reset button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "重置",
            style: .plain,
            target: self,
            action: #selector(resetStateTapped)
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "彈窗系統測試"
        
        // User Segment
        userSegment.selectedSegmentIndex = 0
        userSegment.translatesAutoresizingMaskIntoConstraints = false
        userSegment.addTarget(self, action: #selector(userTypeChanged), for: .valueChanged)
        view.addSubview(userSegment)
        
        // State Switches Container
        let switchesStack = UIStackView()
        switchesStack.axis = .vertical
        switchesStack.spacing = 12
        switchesStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchesStack)
        
        // Helper function to create switch row
        func createSwitchRow(label: String, switchControl: UISwitch) -> UIStackView {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.distribution = .fillProportionally
            
            let titleLabel = UILabel()
            titleLabel.text = label
            titleLabel.font = .systemFont(ofSize: 14)
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            switchControl.setContentHuggingPriority(.required, for: .horizontal)
            
            row.addArrangedSubview(titleLabel)
            row.addArrangedSubview(switchControl)
            return row
        }
        
        switchesStack.addArrangedSubview(createSwitchRow(label: "看過新手教學", switchControl: tutorialSwitch))
        switchesStack.addArrangedSubview(createSwitchRow(label: "看過廣告", switchControl: adSwitch))
        switchesStack.addArrangedSubview(createSwitchRow(label: "看過新功能", switchControl: newFeatureSwitch))
        switchesStack.addArrangedSubview(createSwitchRow(label: "今天已簽到", switchControl: dailyCheckInSwitch))
        switchesStack.addArrangedSubview(createSwitchRow(label: "有預測結果", switchControl: predictionResultSwitch))
        
        // Start Chain Button
        startChainButton.setTitle("啟動彈窗鏈", for: .normal)
        startChainButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startChainButton.backgroundColor = .systemBlue
        startChainButton.setTitleColor(.white, for: .normal)
        startChainButton.layer.cornerRadius = 12
        startChainButton.translatesAutoresizingMaskIntoConstraints = false
        startChainButton.addTarget(self, action: #selector(startChainTapped), for: .touchUpInside)
        view.addSubview(startChainButton)
        
        // Change User Button (模擬重新登入)
        changeUserButton.setTitle("模擬重新登入", for: .normal)
        changeUserButton.titleLabel?.font = .systemFont(ofSize: 16)
        changeUserButton.backgroundColor = .systemGreen
        changeUserButton.setTitleColor(.white, for: .normal)
        changeUserButton.layer.cornerRadius = 12
        changeUserButton.translatesAutoresizingMaskIntoConstraints = false
        changeUserButton.addTarget(self, action: #selector(changeUserTapped), for: .touchUpInside)
        view.addSubview(changeUserButton)
        
        // User Info Label
        userInfoLabel.numberOfLines = 0
        userInfoLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        userInfoLabel.textAlignment = .left
        userInfoLabel.backgroundColor = .systemGray6
        userInfoLabel.layer.cornerRadius = 8
        userInfoLabel.layer.masksToBounds = true
        userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userInfoLabel)
        
        // State Label
        stateLabel.numberOfLines = 0
        stateLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        stateLabel.textAlignment = .left
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stateLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            userSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            switchesStack.topAnchor.constraint(equalTo: userSegment.bottomAnchor, constant: 20),
            switchesStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            switchesStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startChainButton.topAnchor.constraint(equalTo: switchesStack.bottomAnchor, constant: 30),
            startChainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startChainButton.widthAnchor.constraint(equalToConstant: 200),
            startChainButton.heightAnchor.constraint(equalToConstant: 50),
            
            changeUserButton.topAnchor.constraint(equalTo: startChainButton.bottomAnchor, constant: 20),
            changeUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeUserButton.widthAnchor.constraint(equalToConstant: 200),
            changeUserButton.heightAnchor.constraint(equalToConstant: 50),
            
            userInfoLabel.topAnchor.constraint(equalTo: changeUserButton.bottomAnchor, constant: 30),
            userInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stateLabel.topAnchor.constraint(equalTo: userInfoLabel.bottomAnchor, constant: 20),
            stateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupPopupSystem() {
        repository = UserDefaultsPopupStateRepository()
        presenter = UIPopupPresenter()
        presenter?.onStateChanged = { [weak self] in
            self?.updateStateDisplay()
        }
        createChainManager()
    }
    
    private func createChainManager() {
        let userInfo = getCurrentUserInfo()
        chainManager = PopupChainManager(
            userInfo: userInfo,
            stateRepository: repository,
            presenter: presenter,
            logger: ConsoleLogger(),
            popupTransitionDelay: 0.4
        )
    }
    
    private func getCurrentUserInfo() -> UserInfo {
        // 根據開關狀態動態生成 UserInfo
        let memberId = currentMemberId
        
        let lastCheckInDate: Date? = dailyCheckInSwitch.isOn ? Date() : nil
        
        return UserInfo(
            memberId: memberId,
            hasSeenTutorial: tutorialSwitch.isOn,
            hasSeenAd: adSwitch.isOn,
            hasSeenNewFeature: newFeatureSwitch.isOn,
            lastCheckInDate: lastCheckInDate,
            hasPredictionResult: predictionResultSwitch.isOn
        )
    }
    
    @objc private func startChainTapped() {
        print("🚀 啟動彈窗鏈")
        updateStateDisplay()  // 啟動前先更新一次
        chainManager?.startPopupChain()
    }
    
    @objc private func resetStateTapped() {
        // 重置為當前選擇的用戶類型
        repository.resetUser(memberId: currentMemberId)
        
        // 設置開關為預設值
        if userSegment.selectedSegmentIndex == 0 {
            // 新用戶：全部關閉
            tutorialSwitch.isOn = false
            adSwitch.isOn = false
            newFeatureSwitch.isOn = false
            dailyCheckInSwitch.isOn = false
            predictionResultSwitch.isOn = false
        } else {
            // 老用戶：Tutorial 和 Ad 開啟
            tutorialSwitch.isOn = true
            adSwitch.isOn = true
            newFeatureSwitch.isOn = false
            dailyCheckInSwitch.isOn = false
            predictionResultSwitch.isOn = false
            
            // 預填 Repository
            _ = repository.markAsShown(type: .tutorial, memberId: currentMemberId)
            _ = repository.markAsShown(type: .interstitialAd, memberId: currentMemberId)
        }
        
        // 重建管理器
        createChainManager()
        updateStateDisplay()
        print("🔄 已重置為當前用戶類型的初始狀態")
    }
    
    @objc private func changeUserTapped() {        // 從 Repository 讀取狀態，更新開關（模擬重新登入後 Server 返回的 UserInfo）
        let memberId = currentMemberId
        
        let tutorialState = repository.getState(for: .tutorial, memberId: memberId)
        let adState = repository.getState(for: .interstitialAd, memberId: memberId)
        let featureState = repository.getState(for: .newFeature, memberId: memberId)
        let checkInState = repository.getState(for: .dailyCheckIn, memberId: memberId)
        
        tutorialSwitch.isOn = if case .success(let state) = tutorialState { state.hasShown } else { false }
        adSwitch.isOn = if case .success(let state) = adState { state.hasShown } else { false }
        newFeatureSwitch.isOn = if case .success(let state) = featureState { state.hasShown } else { false }
        
        // 檢查是否今天簽到
        if case .success(let state) = checkInState, 
           let lastShown = state.lastShownDate,
           Calendar.current.isDateInToday(lastShown) {
            dailyCheckInSwitch.isOn = true
        } else {
            dailyCheckInSwitch.isOn = false
        }
        
        // 預測結果保持不變（外部數據，不從 Repository 讀取）
                createChainManager()
        updateStateDisplay()
        print("� 模擬重新登入")
    }
    
    @objc private func userTypeChanged() {
        // 切換用戶類型時，自動設置開關為該類型的預設值
        repository.resetUser(memberId: currentMemberId)
        
        if userSegment.selectedSegmentIndex == 0 {
            // 新用戶：全部關閉
            tutorialSwitch.isOn = false
            adSwitch.isOn = false
            newFeatureSwitch.isOn = false
            dailyCheckInSwitch.isOn = false
            predictionResultSwitch.isOn = false
        } else {
            // 老用戶：Tutorial 和 Ad 開啟
            tutorialSwitch.isOn = true
            adSwitch.isOn = true
            newFeatureSwitch.isOn = false
            dailyCheckInSwitch.isOn = false
            predictionResultSwitch.isOn = false
            
            // 預填 Repository（模擬老用戶已有的記錄）
            _ = repository.markAsShown(type: .tutorial, memberId: currentMemberId)
            _ = repository.markAsShown(type: .interstitialAd, memberId: currentMemberId)
        }
        
        createChainManager()
        updateStateDisplay()
    }
    
    @objc private func switchChanged() {
        // 任何開關變化都重建 ChainManager
        createChainManager()
        updateStateDisplay()
    }
    
    private func updateStateDisplay() {
        // UserInfo 顯示 - 當前 ChainManager 持有的 UserInfo（模擬 Server 返回的狀態）
        let userInfo = getCurrentUserInfo()
        var userInfoText = " UserInfo (當前 Session 的初始狀態):\n"
        userInfoText += " • memberId: \(userInfo.memberId)\n"
        userInfoText += " • hasSeenTutorial: \(userInfo.hasSeenTutorial ? "✅" : "❌")\n"
        userInfoText += " • hasSeenAd: \(userInfo.hasSeenAd ? "✅" : "❌")\n"
        userInfoText += " • hasSeenNewFeature: \(userInfo.hasSeenNewFeature ? "✅" : "❌")\n"
        
        if let lastCheckIn = userInfo.lastCheckInDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let isToday = Calendar.current.isDateInToday(lastCheckIn)
            userInfoText += " • lastCheckInDate: \(formatter.string(from: lastCheckIn)) \(isToday ? "📅 今天" : "")\n"
        } else {
            userInfoText += " • lastCheckInDate: nil\n"
        }
        
        userInfoText += " • hasPredictionResult: \(userInfo.hasPredictionResult ? "✅" : "❌")\n "
        userInfoLabel.text = userInfoText
        
        // Repository 狀態顯示 - 持久化記錄
        var text = "Repository 狀態 (持久化記錄):\n\n"
        
        let types: [PopupType] = [.tutorial, .interstitialAd, .newFeature, .dailyCheckIn, .predictionResult]
        for type in types {
            if case .success(let state) = repository.getState(for: type, memberId: currentMemberId) {
                let status = state.hasShown ? "✅ 已顯示" : "⭕️ 未顯示"
                text += "\(type.displayName): \(status) (次數: \(state.showCount))\n"
            }
        }
        
        stateLabel.text = text
    }
}

/// UI implementation of PopupPresenter
class UIPopupPresenter: PopupPresenter {
    
    private weak var currentViewController: UIViewController?
    private var _currentPopupType: PopupType?
    private var currentCompletion: (() -> Void)?
    
    var onStateChanged: (() -> Void)?
    
    var isPresenting: Bool {
        currentViewController != nil
    }
    
    var currentPopupType: PopupType? {
        _currentPopupType
    }
    
    func present(type: PopupType, from viewController: UIViewController, completion: @escaping () -> Void) {
        _currentPopupType = type
        currentCompletion = completion
        
        // Find the top-most view controller to present from
        guard let topVC = getTopViewController() else {
            print("❌ 無法找到可呈現的 view controller")
            completion()
            return
        }
        
        let alertVC = UIAlertController(
            title: type.displayName,
            message: getMessageForType(type),
            preferredStyle: .alert
        )
        
        let closeAction = UIAlertAction(title: "關閉", style: .default) { [weak self] _ in
            self?.currentViewController = nil
            self?._currentPopupType = nil
            self?.onStateChanged?()
            completion()
        }
        
        alertVC.addAction(closeAction)
        
        currentViewController = alertVC
        
        DispatchQueue.main.async { [weak self] in
            topVC.present(alertVC, animated: true)
            self?.onStateChanged?()
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            return nil
        }
        
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        return topVC
    }
    
    func dismiss(type: PopupType) {
        guard _currentPopupType == type else { return }
        currentViewController?.dismiss(animated: true) { [weak self] in
            self?.currentViewController = nil
            self?._currentPopupType = nil
            self?.onStateChanged?()
            self?.currentCompletion?()
            self?.currentCompletion = nil
        }
    }
    
    private func getMessageForType(_ type: PopupType) -> String {
        switch type {
        case .tutorial:
            return "歡迎使用 CodeMonster！\n這是新手教學彈窗。"
        case .interstitialAd:
            return "精選廣告內容\n感謝您的支持！"
        case .newFeature:
            return "全新功能上線！\n快來體驗最新特性。"
        case .dailyCheckIn:
            return "每日簽到\n完成簽到獲得獎勵！"
        case .predictionResult:
            return "預測結果已出爐\n點擊查看詳情。"
        }
    }
}
