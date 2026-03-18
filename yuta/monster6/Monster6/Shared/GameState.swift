import Foundation

enum GameState: Equatable {
    case waiting
    case playing(currentPlayer: Player)
    case finished(result: GameResult)
}

enum Player: Equatable {
    case playerOne
    case playerTwo
    case none
}

enum GameResult: Equatable {
    case win(player: Player)
    case draw
}
