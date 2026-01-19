//
//  PredictionResultHandler.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//
//  User Story 3: 猜多空結果通知
//

import UIKit

/// 猜多空結果資料結構
struct PredictionResult {
    let id: String
    let isCorrect: Bool
}

/// 猜多空結果彈窗處理器
/// 用戶有待顯示的預測結果時顯示
/// 單機模式：內建示範用的預測結果
final class PredictionResultHandler: PopupHandler {

    // MARK: - Properties

    /// 待通知的預測結果（單機模式內建示範資料）
    var pendingResults: [PredictionResult] = [
        PredictionResult(id: "demo_prediction_001", isCorrect: true)
    ]

    // MARK: - PopupHandler

    let popupType: PopupType = .predictionResult

    func shouldDisplay(state: PopupUserState) -> Bool {
        // 檢查是否有未通知的預測結果
        return pendingResults.contains { result in
            !state.hasNotifiedPrediction(id: result.id)
        }
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        // 找出第一個未通知的結果
        guard let result = pendingResults.first(where: { !PopupStateStorage().load().hasNotifiedPrediction(id: $0.id) }) else {
            completion(.dismissed)
            return
        }

        let title = result.isCorrect ? "恭喜猜中！🎉" : "很遺憾，未猜中"
        let message = result.isCorrect
            ? "您的預測正確！獎勵已發放到您的帳戶。"
            : "下次再接再厲！繼續參與猜多空活動。"

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            completion(.completed)
        })

        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

    func updateState(storage: PopupStateStorage) {
        // 標記第一個未通知的結果為已通知
        let state = storage.load()
        if let result = pendingResults.first(where: { !state.hasNotifiedPrediction(id: $0.id) }) {
            storage.markPredictionNotified(id: result.id)
        }
    }
}
