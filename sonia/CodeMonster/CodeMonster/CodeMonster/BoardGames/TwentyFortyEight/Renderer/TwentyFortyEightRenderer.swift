import Foundation

// MARK: - TwentyFortyEightRenderer
// 2048 console 渲染：數字靠右對齊（6 字元寬），顯示分數。
// TODO: T5-4 實作

struct TwentyFortyEightRenderer: BoardRenderer {
    let game: TwentyFortyEightGame

    func render() -> String {
        // TODO: 數字靠右對齊，格子寬度一致（6 字元）
        // ┌──────┬──────┬──────┬──────┐
        // │      │    2 │      │    2 │
        // ...
        // Score: 4,892
        return "🎮 2048\n(TODO: implement renderer)"
    }
}
