import UIKit

// MARK: - MenuViewController
// 棋盤遊戲清單選擇入口。
// 顯示四款遊戲，點擊後 push 對應遊戲 ViewController。
// TODO: T1-1 實作

final class MenuViewController: UIViewController {

    private enum Game: Int, CaseIterable {
        case ticTacToe = 0
        case connectFour
        case reversi
        case twentyFortyEight

        var title: String {
            switch self {
            case .ticTacToe:       return "Tic-Tac-Toe 井字棋"
            case .connectFour:     return "Connect Four 四子棋"
            case .reversi:         return "Reversi 黑白棋"
            case .twentyFortyEight: return "2048"
            }
        }

        var subtitle: String {
            switch self {
            case .ticTacToe:       return "3×3 · Minimax AI"
            case .connectFour:     return "7×6 · Alpha-Beta AI"
            case .reversi:         return "8×8 · 位置權重 AI"
            case .twentyFortyEight: return "4×4 · 單人挑戰"
            }
        }
    }

    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🎮 Board Games"
        setupTableView()
    }

    private func setupTableView() {
        // TODO: T1-1 設置 tableView layout + dataSource/delegate
    }
}

// MARK: - UITableViewDataSource / Delegate
// TODO: T1-1 實作 cell 顯示與點擊導航
