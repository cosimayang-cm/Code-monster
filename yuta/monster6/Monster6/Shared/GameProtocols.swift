import Foundation

// MARK: - Board Protocol
protocol BoardProtocol {
    mutating func reset()
}

// MARK: - Move Protocol
protocol MoveProtocol {}

// MARK: - GameEngine Protocol
protocol GameEngineProtocol: AnyObject {
    associatedtype Board: BoardProtocol
    associatedtype Move: MoveProtocol

    var board: Board { get }
    var state: GameState { get }

    func applyMove(_ move: Move) -> Bool
    func reset()
}

// MARK: - Renderer Protocol
protocol RendererProtocol {
    associatedtype Board: BoardProtocol
    func render(_ board: Board) -> String
}

// MARK: - AI Protocol
protocol AIProtocol {
    associatedtype Board: BoardProtocol
    associatedtype Move: MoveProtocol
    func bestMove(for board: Board) -> Move?
}
