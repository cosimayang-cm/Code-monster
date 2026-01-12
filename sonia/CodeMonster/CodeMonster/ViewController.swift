//
//  ViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let car = Car()
    private var featureButtons: [Feature: UIButton] = [:]
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🚗 Car Control Panel"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let computerStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let engineStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let computerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Central Computer", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let engineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Engine", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let featuresLabel: UILabel = {
        let label = UILabel()
        label.text = "Features"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let featuresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObserver()
        updateAllUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(computerStatusLabel)
        contentView.addSubview(engineStatusLabel)
        contentView.addSubview(computerButton)
        contentView.addSubview(engineButton)
        contentView.addSubview(featuresLabel)
        contentView.addSubview(featuresStackView)
        
        // Setup buttons
        computerButton.addTarget(self, action: #selector(computerButtonTapped), for: .touchUpInside)
        engineButton.addTarget(self, action: #selector(engineButtonTapped), for: .touchUpInside)
        
        // Create feature buttons
        createFeatureButtons()
        
        // Layout
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            computerStatusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            computerStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            computerStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            engineStatusLabel.topAnchor.constraint(equalTo: computerStatusLabel.bottomAnchor, constant: 8),
            engineStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            engineStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            computerButton.topAnchor.constraint(equalTo: engineStatusLabel.bottomAnchor, constant: 20),
            computerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            computerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            computerButton.heightAnchor.constraint(equalToConstant: 50),
            
            engineButton.topAnchor.constraint(equalTo: computerButton.bottomAnchor, constant: 12),
            engineButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            engineButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            engineButton.heightAnchor.constraint(equalToConstant: 50),
            
            featuresLabel.topAnchor.constraint(equalTo: engineButton.bottomAnchor, constant: 30),
            featuresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featuresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            featuresStackView.topAnchor.constraint(equalTo: featuresLabel.bottomAnchor, constant: 12),
            featuresStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featuresStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            featuresStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createFeatureButtons() {
        let features = car.getInstalledFeatures()
        
        for feature in features {
            let button = UIButton(type: .system)
            button.setTitle(feature.displayName, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            button.layer.cornerRadius = 10
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.tag = feature.hashValue
            button.addTarget(self, action: #selector(featureButtonTapped(_:)), for: .touchUpInside)
            
            featureButtons[feature] = button
            featuresStackView.addArrangedSubview(button)
        }
    }
    
    private func setupObserver() {
        car.addObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func computerButtonTapped() {
        if car.isCentralComputerOn {
            car.turnOffCentralComputer()
        } else {
            car.turnOnCentralComputer()
        }
    }
    
    @objc private func engineButtonTapped() {
        if car.isEngineRunning {
            car.stopEngine()
        } else {
            car.startEngine()
        }
    }
    
    @objc private func featureButtonTapped(_ sender: UIButton) {
        guard let feature = featureButtons.first(where: { $0.value == sender })?.key else { return }
        
        if car.isFeatureEnabled(feature) {
            _ = car.disableFeature(feature)
        } else {
            let result = car.enableFeature(feature)
            if case .failure(let error) = result {
                showAlert(title: "Cannot Enable", message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateAllUI() {
        updateComputerUI()
        updateEngineUI()
        updateAllFeatureButtons()
    }
    
    private func updateComputerUI() {
        let isOn = car.isCentralComputerOn
        computerStatusLabel.text = "💻 Central Computer: \(isOn ? "ON" : "OFF")"
        computerStatusLabel.textColor = isOn ? .systemGreen : .systemRed
        
        computerButton.setTitle(isOn ? "Turn OFF Computer" : "Turn ON Computer", for: .normal)
        computerButton.backgroundColor = isOn ? .systemRed.withAlphaComponent(0.2) : .systemGreen.withAlphaComponent(0.2)
        computerButton.setTitleColor(isOn ? .systemRed : .systemGreen, for: .normal)
        
        // 更新引擎按鈕狀態（引擎依賴中控電腦）
        updateEngineUI()
    }
    
    private func updateEngineUI() {
        let isRunning = car.isEngineRunning
        let computerOn = car.isCentralComputerOn
        
        engineStatusLabel.text = "🏃 Engine: \(isRunning ? "RUNNING" : "STOPPED")"
        engineStatusLabel.textColor = isRunning ? .systemGreen : .systemRed
        
        engineButton.setTitle(isRunning ? "Stop Engine" : "Start Engine", for: .normal)
        engineButton.backgroundColor = isRunning ? .systemRed.withAlphaComponent(0.2) : .systemGreen.withAlphaComponent(0.2)
        engineButton.setTitleColor(isRunning ? .systemRed : .systemGreen, for: .normal)
        
        // 中控電腦關閉時，引擎按鈕不可用
        engineButton.isEnabled = computerOn || isRunning
        engineButton.alpha = (computerOn || isRunning) ? 1.0 : 0.5
    }
    
    private func updateAllFeatureButtons() {
        for (feature, button) in featureButtons {
            updateFeatureButton(feature: feature, button: button)
        }
    }
    
    private func updateFeatureButton(feature: Feature, button: UIButton) {
        let isEnabled = car.isFeatureEnabled(feature)
        let isAvailable = car.isFeatureAvailable(feature)
        
        // 更新按鈕標題
        let title = isEnabled ? "✓ \(feature.displayName)" : feature.displayName
        button.setTitle(title, for: .normal)
        
        // 更新按鈕顏色
        if isEnabled {
            button.backgroundColor = .systemGreen.withAlphaComponent(0.3)
            button.setTitleColor(.systemGreen, for: .normal)
        } else if isAvailable {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.label, for: .normal)
        } else {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.systemGray, for: .normal)
        }
        
        // 更新按鈕可點擊狀態
        button.isEnabled = isAvailable || isEnabled
        button.alpha = (isAvailable || isEnabled) ? 1.0 : 0.5
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CarEventObserver

extension ViewController: CarEventObserver {
    
    func carDidChangeState(_ event: CarEvent) {
        switch event {
        case .featureEnabled:
            updateAllFeatureButtons()
            
        case .featureDisabled:
            updateAllFeatureButtons()
            
        case .featuresCascadeDisabled(let features):
            updateAllFeatureButtons()
            let featureNames = features.map { $0.displayName }.joined(separator: "\n")
            showAlert(title: "Features Cascade Disabled", message: "The following features were disabled:\n\n\(featureNames)")
            
        case .centralComputerTurnedOn:
            updateComputerUI()
            updateAllFeatureButtons()
            
        case .centralComputerTurnedOff:
            updateComputerUI()
            updateAllFeatureButtons()
            
        case .engineStarted:
            updateEngineUI()
            updateAllFeatureButtons()
            
        case .engineStopped:
            updateEngineUI()
            updateAllFeatureButtons()
        }
    }
}

