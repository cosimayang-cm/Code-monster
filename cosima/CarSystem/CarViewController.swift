//
//  CarViewController.swift
//  CarSystem
//
//  Created by Claude on 2026/1/11.
//
import UIKit
import Combine

class CarViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var computerButton: UIButton!
    @IBOutlet weak var engineButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let car = Car()
    
    /// Combine 訂閱管理
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        // 確保所有 IBOutlet 都已連接
        guard statusLabel != nil, computerButton != nil, engineButton != nil, tableView != nil else {
            return
        }
        
        // 設置按鈕圓角
        computerButton.layer.cornerRadius = 8
        engineButton.layer.cornerRadius = 8
        
        // 設置狀態標籤
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
        
        // 註冊 TableView Cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FeatureCell")
    }
    
    // MARK: - Combine 資料綁定
    private func setupBindings() {
        // 監聽中控電腦狀態變化 → 自動更新 UI
        car.$isComputerOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatus()
                self?.tableView?.reloadData()
            }
            .store(in: &cancellables)
        
        // 監聽引擎狀態變化 → 自動更新 UI
        car.$isEngineRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatus()
                self?.tableView?.reloadData()
            }
            .store(in: &cancellables)
        
        // 監聽已啟用功能變化 → 自動更新 UI
        car.$enabledFeatures
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatus()
                self?.tableView?.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - IBActions
    @IBAction func toggleComputerTapped(_ sender: UIButton) {
        car.toggleCentralComputer()
        // Combine 會自動觸發 UI 更新，不需要手動調用
    }
    
    @IBAction func toggleEngineTapped(_ sender: UIButton) {
        car.toggleEngine()
        // Combine 會自動觸發 UI 更新，不需要手動調用
    }
    
    // MARK: - UI 更新
    private func updateStatus() {
        let computerStatus = car.isComputerOn ? "✅ 開啟" : "❌ 關閉"
        let engineStatus = car.isEngineRunning ? "✅ 運行中" : "❌ 停止"
        let enabledCount = car.enabledFeatures.count
        
        statusLabel?.text = "中控電腦: \(computerStatus) | 引擎: \(engineStatus) | 已啟用功能: \(enabledCount) 個"
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Feature.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell", for: indexPath)
        let feature = Feature.allCases[indexPath.row]
        
        // 取得功能對應的元件（所有資訊都在元件裡）
        let component = car.component(for: feature)
        
        var config = cell.defaultContentConfiguration()
        config.text = component.name
        config.secondaryText = component.description
        
        let isEnabled = car.isFeatureEnabled(feature)
        cell.accessoryType = isEnabled ? .checkmark : .none
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let feature = Feature.allCases[indexPath.row]
        
        if car.isFeatureEnabled(feature) {
            // 停用功能
            switch car.disable(feature) {
            case .success:
                // Combine 會自動更新 UI
                break
            case .failure(let error):
                showAlert(message: "停用失敗: \(error.localizedDescription)")
            }
        } else {
            // 啟用功能
            switch car.enable(feature) {
            case .success:
                // Combine 會自動更新 UI
                break
            case .failure(let error):
                showAlert(message: "啟用失敗: \(error.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "功能列表（點擊切換）"
    }
}
