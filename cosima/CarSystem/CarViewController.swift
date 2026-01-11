//
//  CarViewController.swift
//  CarSystem
//
//  Created by Claude on 2026/1/11.
//
import UIKit

class CarViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var computerButton: UIButton!
    @IBOutlet weak var engineButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let car = Car()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatus()
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
        
        // 註冊 TableView Cell (不需要再設置 delegate 和 dataSource，已在 Storyboard 連接)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FeatureCell")
    }
    
    // MARK: - IBActions
    @IBAction func toggleComputerTapped(_ sender: UIButton) {
        if car.centralComputer.isOn {
            car.centralComputer.turnOff()
            car.syncCentralComputerState()
        } else {
            car.centralComputer.turnOn()
        }
        updateStatus()
        tableView.reloadData()
    }
    
    @IBAction func toggleEngineTapped(_ sender: UIButton) {
        if car.engine.isRunning {
            car.engine.stop()
            car.syncEngineState()
        } else {
            car.engine.start()
        }
        updateStatus()
        tableView.reloadData()
    }
    
    private func updateStatus() {
        let computerStatus = car.centralComputer.isOn ? "✅ 開啟" : "❌ 關閉"
        let engineStatus = car.engine.isRunning ? "✅ 運行中" : "❌ 停止"
        let enabledCount = car.enabledFeatures.count
        
        statusLabel.text = "中控電腦: \(computerStatus) | 引擎: \(engineStatus) | 已啟用功能: \(enabledCount) 個"
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
        
        var config = cell.defaultContentConfiguration()
        config.text = feature.displayName
        config.secondaryText = feature.description
        
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
                break
            case .failure(let error):
                showAlert(message: "停用失敗: \(error.localizedDescription)")
            }
        } else {
            // 啟用功能
            switch car.enable(feature) {
            case .success:
                break
            case .failure(let error):
                showAlert(message: "啟用失敗: \(error.localizedDescription)")
            }
        }
        
        updateStatus()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "功能列表（點擊切換）"
    }
}
