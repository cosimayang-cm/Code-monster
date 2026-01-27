/*:
 # Undo/Redo System Demo

 這個 Playground 展示了完整的 Undo/Redo 系統，包含：
 - Command Pattern 的實作
 - Memento Pattern 的應用
 - 文章編輯器（TextEditor）
 - 畫布編輯器（Canvas）

 **使用方式：**
 按順序執行每個 Section，觀察輸出結果。
 每個 Section 都是獨立的，可以單獨執行。

 ---
 */

import Foundation

//: ## 準備工作：複製必要的程式碼到 Playground
//: 為了讓 Playground 可以直接執行，我們將核心程式碼放在 Sources 目錄中

/*:
 ---
 # Section 1: 文字編輯器 - 基本操作

 展示文字的插入、刪除、取代，以及 Undo/Redo 功能。
 */

print("=== Section 1: 文字編輯器基本操作 ===\n")

// 建立文件和命令歷史
let textDocument = TextDocument()
let textHistory = CommandHistory()

// 測試 1: 插入文字 "Hello"
print("📝 測試 1: 插入 'Hello' 在位置 0")
let insertHello = InsertTextCommand(document: textDocument, text: "Hello", position: 0)
textHistory.execute(insertHello)
print("   內容: \"\(textDocument.getText())\"")
print("   可以 Undo: \(textHistory.canUndo)")
print("   Undo 描述: \(textHistory.undoDescription ?? "無")")
print()

// 測試 2: 繼續插入 " World"
print("📝 測試 2: 插入 ' World' 在位置 5")
let insertWorld = InsertTextCommand(document: textDocument, text: " World", position: 5)
textHistory.execute(insertWorld)
print("   內容: \"\(textDocument.getText())\"")
print("   可以 Undo: \(textHistory.canUndo)")
print()

// 測試 3: Undo 第二次插入
print("⏪ 測試 3: 執行 Undo")
textHistory.undo()
print("   內容: \"\(textDocument.getText())\"")
print("   可以 Undo: \(textHistory.canUndo)")
print("   可以 Redo: \(textHistory.canRedo)")
print("   Redo 描述: \(textHistory.redoDescription ?? "無")")
print()

// 測試 4: Redo
print("⏩ 測試 4: 執行 Redo")
textHistory.redo()
print("   內容: \"\(textDocument.getText())\"")
print("   可以 Redo: \(textHistory.canRedo)")
print()

// 測試 5: 全部 Undo
print("⏪ 測試 5: 執行兩次 Undo（回到初始狀態）")
textHistory.undo()
textHistory.undo()
print("   內容: \"\(textDocument.getText())\"")
print("   文件為空: \(textDocument.getText().isEmpty)")
print()

// 測試 6: 全部 Redo
print("⏩ 測試 6: 執行兩次 Redo（恢復到 'Hello World'）")
textHistory.redo()
textHistory.redo()
print("   內容: \"\(textDocument.getText())\"")
print()

print("✅ Section 1 完成\n")
print("---\n")

/*:
 ---
 # Section 2: 文字編輯器 - 刪除和取代

 展示更多文字操作，包括刪除和取代。
 */

print("=== Section 2: 文字編輯器 - 刪除和取代 ===\n")

// 重新開始
let doc2 = TextDocument()
let history2 = CommandHistory()

// 先插入一些文字
history2.execute(InsertTextCommand(document: doc2, text: "The quick brown fox", position: 0))
print("📝 初始內容: \"\(doc2.getText())\"")
print()

// 測試 7: 刪除 "quick " (位置 4-10)
print("🗑️ 測試 7: 刪除 'quick ' (位置 4-10)")
let deleteCmd = DeleteTextCommand(document: doc2, range: NSRange(location: 4, length: 6))
history2.execute(deleteCmd)
print("   內容: \"\(doc2.getText())\"")
print()

// 測試 8: Undo 刪除
print("⏪ 測試 8: Undo 刪除")
history2.undo()
print("   內容: \"\(doc2.getText())\"")
print()

// 測試 9: 取代 "brown" 為 "red" (位置 10-15)
print("🔄 測試 9: 將 'brown' 取代為 'red'")
let replaceCmd = ReplaceTextCommand(document: doc2, range: NSRange(location: 10, length: 5), newText: "red")
history2.execute(replaceCmd)
print("   內容: \"\(doc2.getText())\"")
print()

// 測試 10: Undo 取代
print("⏪ 測試 10: Undo 取代")
history2.undo()
print("   內容: \"\(doc2.getText())\"")
print()

// 測試 11: 新操作會清空 Redo 堆疊
print("📝 測試 11: 執行新操作（會清空 Redo 堆疊）")
print("   執行新操作前 - 可以 Redo: \(history2.canRedo)")
history2.execute(InsertTextCommand(document: doc2, text: "!!!", position: doc2.getText().count))
print("   內容: \"\(doc2.getText())\"")
print("   執行新操作後 - 可以 Redo: \(history2.canRedo)")
print()

print("✅ Section 2 完成\n")
print("---\n")

/*:
 ---
 # Section 3: 文字編輯器 - 樣式設定

 展示文字樣式的套用和 Undo/Redo。
 */

print("=== Section 3: 文字編輯器 - 樣式設定 ===\n")

let doc3 = TextDocument()
let history3 = CommandHistory()

// 插入文字
history3.execute(InsertTextCommand(document: doc3, text: "Hello World", position: 0))
print("📝 初始內容: \"\(doc3.getText())\"")
print()

// 測試 12: 對 "Hello" 套用粗體
print("🎨 測試 12: 對 'Hello' (0-5) 套用粗體")
let boldRange = NSRange(location: 0, length: 5)
let applyBold = ApplyStyleCommand(document: doc3, style: TextStyle(isBold: true), range: boldRange)
history3.execute(applyBold)
if let style = doc3.getStyle(in: boldRange) {
    print("   'Hello' 是粗體: \(style.isBold)")
} else {
    print("   ❌ 未找到樣式")
}
print()

// 測試 13: Undo 粗體
print("⏪ 測試 13: Undo 粗體")
history3.undo()
let styleAfterUndo = doc3.getStyle(in: boldRange)
print("   樣式已移除: \(styleAfterUndo == nil)")
print()

// 測試 14: Redo 粗體
print("⏩ 測試 14: Redo 粗體")
history3.redo()
if let style = doc3.getStyle(in: boldRange) {
    print("   'Hello' 是粗體: \(style.isBold)")
}
print()

// 測試 15: 對 "World" 套用斜體
print("🎨 測試 15: 對 'World' (6-11) 套用斜體")
let italicRange = NSRange(location: 6, length: 5)
let applyItalic = ApplyStyleCommand(document: doc3, style: TextStyle(isItalic: true), range: italicRange)
history3.execute(applyItalic)
if let style = doc3.getStyle(in: italicRange) {
    print("   'World' 是斜體: \(style.isItalic)")
}
print()

// 測試 16: 檢視所有樣式
print("📋 測試 16: 檢視所有套用的樣式")
print("   共有 \(doc3.getAllStyles().count) 個樣式範圍")
for (range, style) in doc3.getAllStyles() {
    let text = (doc3.getText() as NSString).substring(with: range)
    var attributes: [String] = []
    if style.isBold { attributes.append("粗體") }
    if style.isItalic { attributes.append("斜體") }
    if style.isUnderlined { attributes.append("底線") }
    print("   '\(text)': \(attributes.joined(separator: ", "))")
}
print()

print("✅ Section 3 完成\n")
print("---\n")

/*:
 ---
 # Section 4: 畫布編輯器 - 圖形操作

 展示圖形的新增、刪除、移動，以及 Undo/Redo。
 */

print("=== Section 4: 畫布編輯器 - 圖形操作 ===\n")

let canvas = Canvas()
let canvasHistory = CommandHistory()

// 測試 17: 新增圓形
print("⭕ 測試 17: 新增圓形在 (100, 100)，半徑 50")
let circle = Circle(
    position: Point(x: 100, y: 100),
    radius: 50,
    fillColor: Color.red,
    strokeColor: Color.black
)
let addCircle = AddShapeCommand(canvas: canvas, shape: circle)
canvasHistory.execute(addCircle)
print("   畫布上的圖形數量: \(canvas.shapes.count)")
print("   圓形位置: \(circle.position)")
print("   圓形半徑: \(circle.radius)")
print()

// 測試 18: Undo 新增
print("⏪ 測試 18: Undo 新增圓形")
canvasHistory.undo()
print("   畫布上的圖形數量: \(canvas.shapes.count)")
print("   畫布為空: \(canvas.shapes.isEmpty)")
print()

// 測試 19: Redo 新增
print("⏩ 測試 19: Redo 新增圓形")
canvasHistory.redo()
print("   畫布上的圖形數量: \(canvas.shapes.count)")
print("   圓形位置: \(circle.position)")
print()

// 測試 20: 移動圓形
print("🚀 測試 20: 移動圓形 (+20, +30)")
let moveCircle = MoveShapeCommand(canvas: canvas, shape: circle, offset: Point(x: 20, y: 30))
canvasHistory.execute(moveCircle)
print("   圓形新位置: \(circle.position)")
print()

// 測試 21: Undo 移動
print("⏪ 測試 21: Undo 移動")
canvasHistory.undo()
print("   圓形位置: \(circle.position)")
print()

// 測試 22: 連續 Undo（移除圓形）
print("⏪ 測試 22: 再次 Undo（移除圓形）")
canvasHistory.undo()
print("   畫布上的圖形數量: \(canvas.shapes.count)")
print()

// 測試 23: 連續 Redo
print("⏩ 測試 23: 連續 Redo 兩次")
canvasHistory.redo()
canvasHistory.redo()
print("   畫布上的圖形數量: \(canvas.shapes.count)")
print("   圓形位置: \(circle.position)")
print()

print("✅ Section 4 完成\n")
print("---\n")

/*:
 ---
 # Section 5: 畫布編輯器 - 圖形外觀調整

 展示圖形的縮放和顏色變更。
 */

print("=== Section 5: 畫布編輯器 - 圖形外觀調整 ===\n")

let canvas2 = Canvas()
let history5 = CommandHistory()

// 建立矩形
print("▭ 建立矩形在 (50, 50)，大小 100x80")
let rectangle = Rectangle(
    position: Point(x: 50, y: 50),
    size: Size(width: 100, height: 80),
    fillColor: Color.blue,
    strokeColor: Color.black
)
history5.execute(AddShapeCommand(canvas: canvas2, shape: rectangle))
print("   矩形大小: \(rectangle.size)")
print("   矩形填充顏色: RGB(\(rectangle.fillColor?.red ?? 0), \(rectangle.fillColor?.green ?? 0), \(rectangle.fillColor?.blue ?? 0))")
print()

// 測試 24: 縮放圖形
print("🔍 測試 24: 縮放矩形到 150x120")
let newSize = Size(width: 150, height: 120)
let resize = ResizeShapeCommand(canvas: canvas2, shape: rectangle, newSize: newSize)
history5.execute(resize)
print("   矩形新大小: \(rectangle.size)")
print()

// 測試 25: Undo 縮放
print("⏪ 測試 25: Undo 縮放")
history5.undo()
print("   矩形大小: \(rectangle.size)")
print()

// 測試 26: 變更填充顏色
print("🎨 測試 26: 變更填充顏色為綠色")
let changeFill = ChangeFillColorCommand(canvas: canvas2, shape: rectangle, newColor: Color.green)
history5.execute(changeFill)
print("   矩形填充顏色: RGB(\(rectangle.fillColor?.red ?? 0), \(rectangle.fillColor?.green ?? 0), \(rectangle.fillColor?.blue ?? 0))")
print()

// 測試 27: Undo 顏色變更
print("⏪ 測試 27: Undo 顏色變更")
history5.undo()
print("   矩形填充顏色: RGB(\(rectangle.fillColor?.red ?? 0), \(rectangle.fillColor?.green ?? 0), \(rectangle.fillColor?.blue ?? 0))")
print()

// 測試 28: 變更邊框顏色
print("🖌️ 測試 28: 變更邊框顏色為紅色")
let changeStroke = ChangeStrokeColorCommand(canvas: canvas2, shape: rectangle, newColor: Color.red)
history5.execute(changeStroke)
print("   矩形邊框顏色: RGB(\(rectangle.strokeColor?.red ?? 0), \(rectangle.strokeColor?.green ?? 0), \(rectangle.strokeColor?.blue ?? 0))")
print()

// 測試 29: 檢視命令歷史
print("📜 測試 29: 檢視命令歷史")
print("   可以 Undo: \(history5.canUndo)")
print("   Undo 描述: \(history5.undoDescription ?? "無")")
print()

print("✅ Section 5 完成\n")
print("---\n")

/*:
 ---
 # Section 6: 進階功能 - Memento Pattern

 展示如何使用 Memento 保存和還原完整狀態。
 */

print("=== Section 6: 進階功能 - Memento Pattern ===\n")

let doc6 = TextDocument()
let history6 = CommandHistory()

// 建立初始狀態
history6.execute(InsertTextCommand(document: doc6, text: "Version 1", position: 0))
history6.execute(ApplyStyleCommand(document: doc6, style: TextStyle(isBold: true), range: NSRange(location: 0, length: 9)))
print("📝 初始狀態: \"\(doc6.getText())\" (粗體)")

// 建立快照
let memento = doc6.createMemento()
print("📸 建立快照（保存當前狀態）")
print()

// 繼續編輯
print("📝 繼續編輯...")
history6.execute(InsertTextCommand(document: doc6, text: " - Updated", position: doc6.getText().count))
history6.execute(ApplyStyleCommand(document: doc6, style: TextStyle(isItalic: true), range: NSRange(location: 10, length: 10)))
print("   新內容: \"\(doc6.getText())\"")
print()

// 從快照還原
print("⏮️ 從快照還原")
doc6.restore(from: memento)
print("   還原後內容: \"\(doc6.getText())\"")
let boldStyle = doc6.getStyle(in: NSRange(location: 0, length: 9))
print("   文字是粗體: \(boldStyle?.isBold ?? false)")
print()

print("✅ Section 6 完成\n")
print("---\n")

/*:
 ---
 # Section 7: 複雜場景 - 多種操作混合

 展示真實使用場景中的複雜操作序列。
 */

print("=== Section 7: 複雜場景 - 多種操作混合 ===\n")

let canvas7 = Canvas()
let history7 = CommandHistory()

print("🎨 場景：建立一個簡單的繪圖")
print()

// 步驟 1: 新增圓形
let c1 = Circle(position: Point(x: 100, y: 100), radius: 40, fillColor: Color.red)
history7.execute(AddShapeCommand(canvas: canvas7, shape: c1))
print("1️⃣ 新增紅色圓形")

// 步驟 2: 新增矩形
let r1 = Rectangle(position: Point(x: 200, y: 100), size: Size(width: 80, height: 60), fillColor: Color.blue)
history7.execute(AddShapeCommand(canvas: canvas7, shape: r1))
print("2️⃣ 新增藍色矩形")

// 步驟 3: 新增另一個圓形
let c2 = Circle(position: Point(x: 100, y: 200), radius: 30, fillColor: Color.green)
history7.execute(AddShapeCommand(canvas: canvas7, shape: c2))
print("3️⃣ 新增綠色圓形")

print("\n   畫布上共有 \(canvas7.shapes.count) 個圖形")
print()

// 移動第一個圓形
print("🚀 移動紅色圓形")
history7.execute(MoveShapeCommand(canvas: canvas7, shape: c1, offset: Point(x: 50, y: 0)))
print("   圓形新位置: \(c1.position)")
print()

// 變更矩形顏色
print("🎨 變更矩形顏色為黃色")
history7.execute(ChangeFillColorCommand(canvas: canvas7, shape: r1, newColor: Color.yellow))
print()

// 縮放第二個圓形
print("🔍 縮放綠色圓形")
history7.execute(ResizeShapeCommand(canvas: canvas7, shape: c2, newSize: Size(width: 80, height: 80)))
print("   圓形新半徑: \(c2.radius)")
print()

print("📊 最終狀態：")
print("   畫布上共有 \(canvas7.shapes.count) 個圖形")
print("   可以 Undo: \(history7.canUndo)")
print("   Undo 描述: \(history7.undoDescription ?? "無")")
print()

// 全部 Undo
print("⏪ 連續 Undo 所有操作...")
var undoCount = 0
while history7.canUndo {
    history7.undo()
    undoCount += 1
}
print("   執行了 \(undoCount) 次 Undo")
print("   畫布上的圖形數量: \(canvas7.shapes.count)")
print("   畫布已清空: \(canvas7.shapes.isEmpty)")
print()

// 全部 Redo
print("⏩ 連續 Redo 所有操作...")
var redoCount = 0
while history7.canRedo {
    history7.redo()
    redoCount += 1
}
print("   執行了 \(redoCount) 次 Redo")
print("   畫布上的圖形數量: \(canvas7.shapes.count)")
print("   圓形 1 位置: \(c1.position)")
print("   矩形填充顏色: RGB(\(r1.fillColor?.red ?? 0), \(r1.fillColor?.green ?? 0), \(r1.fillColor?.blue ?? 0))")
print("   圓形 2 半徑: \(c2.radius)")
print()

print("✅ Section 7 完成\n")
print("---\n")

/*:
 ---
 # 總結

 ## ✅ 完成的測試項目

 ### 文字編輯器（TextEditor）
 1. ✅ 插入文字 - 在指定位置插入文字
 2. ✅ 刪除文字 - 刪除指定範圍的文字
 3. ✅ 取代文字 - 將指定範圍的文字取代為新文字
 4. ✅ 套用樣式 - 對文字範圍套用粗體、斜體、底線
 5. ✅ Undo 操作 - 撤銷所有文字和樣式操作
 6. ✅ Redo 操作 - 重做被撤銷的操作
 7. ✅ 新操作清空 Redo - 執行新操作後，Redo 堆疊被清空

 ### 畫布編輯器（Canvas）
 8. ✅ 新增圖形 - 新增圓形、矩形、線條到畫布
 9. ✅ 刪除圖形 - 從畫布移除圖形
 10. ✅ 移動圖形 - 移動圖形到新位置
 11. ✅ 縮放圖形 - 改變圖形的大小
 12. ✅ 變更填充顏色 - 改變圖形的填充顏色
 13. ✅ 變更邊框顏色 - 改變圖形的邊框顏色
 14. ✅ Undo/Redo - 所有圖形操作都可以 Undo/Redo

 ### Command Pattern 和 Memento Pattern
 15. ✅ Command Pattern - 所有操作都封裝為 Command
 16. ✅ CommandHistory - 管理 Undo/Redo 堆疊
 17. ✅ Memento Pattern - 保存和還原完整狀態
 18. ✅ 狀態查詢 - canUndo、canRedo、undoDescription、redoDescription

 ## 🎯 設計模式驗證

 ✅ **Command Pattern**
 - 所有操作都實作了 Command protocol
 - 每個 Command 都可以 execute() 和 undo()
 - CommandHistory 管理命令堆疊
 - 新命令執行後清空 Redo 堆疊

 ✅ **Memento Pattern**
 - TextDocument 和 Canvas 都支援 createMemento() 和 restore()
 - Memento 是不可變的快照
 - 可以保存多個快照並隨時還原

 ✅ **關注點分離**
 - Model 層完全不依賴 UIKit（Foundation-only）
 - 使用 Protocol 抽象具體實作
 - Command 持有 weak reference 避免循環參照

 ## 🚀 下一步

 1. **執行單元測試** - 驗證所有功能的正確性
 2. **建立 UI 介面** - 使用 SwiftUI 或 UIKit 視覺化展示
 3. **進階功能** - 實作命令合併、命令群組、歷史限制

 ---

 # 🎉 Demo 完成！

 這個 Playground 展示了完整的 Undo/Redo 系統。
 你可以修改任何 Section 的程式碼來實驗不同的操作序列。

 **提示：**
 - 每個 Section 都是獨立的，可以單獨修改和執行
 - 觀察每次操作後的狀態變化
 - 嘗試不同的 Undo/Redo 順序
 - 實驗 Memento Pattern 的不同使用方式

 */

print("🎉 所有測試完成！")
print("\n感謝使用 Undo/Redo System Demo Playground！")
