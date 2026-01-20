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
        case 1: return "returning-user"
        case 2: return "experienced-user"
        case 3: return "checked-in-user"
        case 4: return "all-completed-user"
        default: return "new-user"
        }
    }
    
    // UI Elements
    private let titleLabel = UILabel()
    private let startChainButton = UIButton(type: .system)
    private let changeUserButton = UIButton(type: .system)
    private let userInfoLabel = UILabel()
    private let stateLabel = UILabel()
    private let userSegment = UISegmentedControl(items: ["新用戶", "回訪用戶", "老用戶", "已簽到", "全完成"])
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
        
        // Title
        titleLabel.text = "彈窗系統測試"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // User Segment
        userSegment.selectedSegmentIndex = 0
        userSegment.translatesAutoresizingMaskIntoConstraints = false
        userSegment.addTarget(self, action: #selector(userTypeChanged), for: .valueChanged)
        view.addSubview(userSegment)
        
        // Prediction Result Switch
        let predictionSwitchContainer = UIStackView()
        predictionSwitchContainer.axis = .horizontal
        predictionSwitchContainer.spacing = 10
        predictionSwitchContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let predictionLabel = UILabel()
        predictionLabel.text = "有預測結果"
        predictionLabel.font = .systemFont(ofSize: 14)
        
        predictionResultSwitch.addTarget(self, action: #selector(predictionSwitchChanged), for: .valueChanged)
        
        predictionSwitchContainer.addArrangedSubview(predictionLabel)
        predictionSwitchContainer.addArrangedSubview(predictionResultSwitch)
        view.addSubview(predictionSwitchContainer)
        
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
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            userSegment.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            userSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            predictionSwitchContainer.topAnchor.constraint(equalTo: userSegment.bottomAnchor, constant: 20),
            predictionSwitchContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            startChainButton.topAnchor.constraint(equalTo: predictionSwitchContainer.bottomAnchor, constant: 30),
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
        // 從 Repository 讀取實際狀態，模擬重新登入後 Server 返回的 UserInfo
        let memberId = currentMemberId
        
        // 讀取 Repository 中的狀態
        let tutorialState = repository.getState(for: .tutorial, memberId: memberId)
        let adState = repository.getState(for: .interstitialAd, memberId: memberId)
        let featureState = repository.getState(for: .newFeature, memberId: memberId)
        let checkInState = repository.getState(for: .dailyCheckIn, memberId: memberId)
        let predictionState = repository.getState(for: .predictionResult, memberId: memberId)
        
        let hasSeenTutorial = if case .success(let state) = tutorialState { state.hasShown } else { false }
        let hasSeenAd = if case .success(let state) = adState { state.hasShown } else { false }
        let hasSeenNewFeature = if case .success(let state) = featureState { state.hasShown } else { false }
        
        let lastCheckInDate: Date? = if case .success(let state) = checkInState, state.hasShown {
            state.lastShownDate
        } else {
            nil
        }
        
        // 使用開關狀態而非 repository（因為預測結果是外部數據，不是彈窗執行狀態）
        let hasPredictionResult = predictionResultSwitch.isOn
        
        return UserInfo(
            memberId: memberId,
            hasSeenTutorial: hasSeenTutorial,
            hasSeenAd: hasSeenAd,
            hasSeenNewFeature: hasSeenNewFeature,
            lastCheckInDate: lastCheckInDate,
            hasPredictionResult: hasPredictionResult
        )
    }
    
    @objc private func startChainTapped() {
        print("🚀 啟動彈窗鏈")
        updateStateDisplay()  // 啟動前先更新一次
        chainManager?.startPopupChain()
    }
    
    @objc private func resetStateTapped() {
        // 清空 repository
        repository.resetUser(memberId: currentMemberId)
        
        // 根據用戶類型恢復初始設定
        let baseInfo: UserInfo
        switch userSegment.selectedSegmentIndex {
        case 0: baseInfo = .newUser
        case 1: baseInfo = .returningUser
        case 2: baseInfo = .experiencedUser
        case 3: baseInfo = .checkedInUser
        case 4: baseInfo = .allCompletedUser
        default: baseInfo = .newUser
        }
        
        // 預填該用戶類型的初始狀態
        if baseInfo.hasSeenTutorial {
            _ = repository.markAsShown(type: .tutorial, memberId: currentMemberId)
        }
        if baseInfo.hasSeenAd {
            _ = repository.markAsShown(type: .interstitialAd, memberId: currentMemberId)
        }
        if baseInfo.hasSeenNewFeature {
            _ = repository.markAsShown(type: .newFeature, memberId: currentMemberId)
        }
        if let lastCheckIn = baseInfo.lastCheckInDate, Calendar.current.isDateInToday(lastCheckIn) {
            _ = repository.markAsShown(type: .dailyCheckIn, memberId: currentMemberId)
        }
        if baseInfo.hasPredictionResult {
            _ = repository.markAsShown(type: .predictionResult, memberId: currentMemberId)
        }
        
        // 重建管理器以使用新的 UserInfo
        createChainManager()
        updateStateDisplay()
        print("🔄 已重置為當前用戶類型的初始狀態")
    }
    
    @objc private func changeUserTapped() {
        createChainManager()
        updateStateDisplay()
        print("� 模擬重新登入")
    }
    
    @objc private func userTypeChanged() {
        // 切換用戶類型時，根據預設值設置開關狀態並預填 repository
        let baseInfo: UserInfo
        switch userSegment.selectedSegmentIndex {
        case 0: baseInfo = .newUser
        case 1: baseInfo = .returningUser
        case 2: baseInfo = .experiencedUser
        case 3: baseInfo = .checkedInUser
        case 4: baseInfo = .allCompletedUser
        default: baseInfo = .newUser
        }
        
        predictionResultSwitch.isOn = baseInfo.hasPredictionResult
        
        // 自動重置並預填該用戶類型的初始狀態
        repository.resetUser(memberId: currentMemberId)
        
        if baseInfo.hasSeenTutorial {
            _ = repository.markAsShown(type: .tutorial, memberId: currentMemberId)
        }
        if baseInfo.hasSeenAd {
            _ = repository.markAsShown(type: .interstitialAd, memberId: currentMemberId)
        }
        if baseInfo.hasSeenNewFeature {
            _ = repository.markAsShown(type: .newFeature, memberId: currentMemberId)
        }
        if let lastCheckIn = baseInfo.lastCheckInDate, Calendar.current.isDateInToday(lastCheckIn) {
            _ = repository.markAsShown(type: .dailyCheckIn, memberId: currentMemberId)
        }
        if baseInfo.hasPredictionResult {
            _ = repository.markAsShown(type: .predictionResult, memberId: currentMemberId)
        }
        
        createChainManager()
        updateStateDisplay()
    }
    
    @objc private func predictionSwitchChanged() {
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
