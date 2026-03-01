import Foundation

struct Game2048Renderer: RendererProtocol {
    func render(_ board: Game2048Board) -> String {
        var lines: [String] = []
        let size = Game2048Board.size

        lines.append("2048")
        lines.append("──────────────────────")
        lines.append("┌──────\(String(repeating: "┬──────", count: size - 1))┐")

        for r in 0..<size {
            let cells = board.cells[r].map { val -> String in
                let str = val == 0 ? "" : "\(val)"
                return str.count < 6 ? String(repeating: " ", count: 6 - str.count) + str : str
            }
            lines.append("│\(cells.joined(separator: "│"))│")
            if r < size - 1 {
                lines.append("├──────\(String(repeating: "┼──────", count: size - 1))┤")
            }
        }
        lines.append("└──────\(String(repeating: "┴──────", count: size - 1))┘")

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let scoreStr = formatter.string(from: NSNumber(value: board.score)) ?? "\(board.score)"
        lines.append("\nScore: \(scoreStr)")
        lines.append("Swipe: Up Down Left Right")

        return lines.joined(separator: "\n")
    }
}
