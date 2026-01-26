### **1. Command Pattern (命令模式)**

**目標：** Command Pattern 的核心目標是將一個「請求」封裝成一個「物件」，從而讓你可以用不同的請求對客戶進行參數化、將請求排入佇列或記錄請求，並支援可撤銷的操作。在這個 Undo/Redo 系統中，它讓每個編輯操作（例如「插入文字」、「新增圖形」）都能被視為一個獨立的物件來執行和撤銷。

#### **Command Protocol (命令協議)**

文件中的 `Command` protocol 定義了所有可執行、可撤銷命令的標準介面。

*   **`execute()` 方法**：這是執行命令的主要方法。當一個命令被「執行」時，它會對其所持有的「接收者」（Receiver，例如 `TextDocument` 或 `Canvas`）進行相應的修改操作。
*   **`undo()` 方法**：這是撤銷命令的核心方法。為了實現撤銷，每個具體的 Command 物件在 `execute()` 執行前或執行中，必須保存足夠的資訊，以便在 `undo()` 被呼叫時能將 Receiver 恢復到命令執行前的狀態。例如，`DeleteTextCommand` 在執行時需要記住被刪除的文字內容和位置，以便 `undo()` 時能將其插入回去。
*   **`description` 屬性**：一個字串屬性，用於提供命令的描述，例如「插入文字」或「移動圖形」。這個描述對於 UI 顯示（例如 Undo 按鈕旁邊顯示「Undo 插入文字」）非常有用，提升使用者體驗。

**設計限制：** `Command` protocol 及其具體實作類別**只能 import Foundation**。這確保了核心邏輯層與任何 UI 框架解耦，使得這部分程式碼可以獨立測試，並適用於不同的平台或 UI 技術。

#### **CommandHistory (命令歷史管理器)**

`CommandHistory` 類別是整個 Undo/Redo 系統的「協調者」。它管理著兩個關鍵的堆疊（Stack）：

*   **`undoStack` (撤銷堆疊)**：儲存所有已成功執行並可被撤銷的 Command 物件。
*   **`redoStack` (重做堆疊)**：儲存所有已被撤銷，但可被重新執行的 Command 物件。

它提供的核心方法和屬性包括：

*   **`execute(_ command:)` 方法**：
    1.  呼叫傳入 `command` 物件的 `execute()` 方法，實際執行操作。
    2.  如果執行成功，將該 `command` 物件推入 `undoStack` 頂部。
    3.  **關鍵邏輯：** 每次執行一個新命令時，`redoStack` 會被清空。因為執行一個新命令會開啟一個新的操作歷史分支，之前被撤銷的命令就不再有效。
*   **`undo()` 方法**：
    1.  從 `undoStack` 彈出最上層的 Command 物件。
    2.  呼叫該 Command 物件的 `undo()` 方法，撤銷其操作。
    3.  將該 Command 物件推入 `redoStack` 頂部。
*   **`redo()` 方法**：
    1.  從 `redoStack` 彈出最上層的 Command 物件。
    2.  呼叫該 Command 物件的 `execute()` 方法，重新執行操作。
    3.  將該 Command 物件推入 `undoStack` 頂部。
*   **`canUndo` / `canRedo` 屬性**：布林值，指示 `undoStack` 或 `redoStack` 是否為空，用於控制 UI 上 Undo/Redo 按鈕的啟用狀態。
*   **`undoDescription` / `redoDescription` 屬性**：返回下一個將要被撤銷或重做命令的 `description`，用於 UI 提示。

**設計限制：** `CommandHistory` 類別同樣**只能 import Foundation**，確保其純邏輯性。

#### **接收者 (Receiver)**

在 Command Pattern 中，執行命令的實際對象被稱為接收者。文件提到了：
*   **`TextDocument`**：文章編輯器的接收者，負責文字內容和樣式的實際管理。
*   **`Canvas`**：畫布編輯器的接收者，負責圖形物件的實際管理。
具體的 Command 物件會持有對這些接收者的引用，並在 `execute()` 或 `undo()` 時呼叫接收者的方法來執行或撤銷操作。

---

### **2. Memento Pattern (備忘錄模式)**

**目標：** Memento Pattern 的核心目標是在不破壞物件封裝性的前提下，捕捉和儲存物件的內部狀態，以便將來能夠將物件恢復到這個狀態。在複雜的編輯系統中，單純依賴 Command 的反向操作可能不足以應對所有情況，這時 Memento Pattern 就顯得非常有用。

#### **Memento 應用時機：**

文件明確指出 Memento Pattern 適用於以下情境：

1.  **Command 無法輕易反向操作時**：
    *   某些 Command 操作可能非常複雜（例如批次處理大量數據），其反向操作邏輯難以設計，或者執行效率極低。
    *   在這種情況下，在執行命令前保存 Receiver 的完整狀態 Memento，並在 `undo()` 時直接恢復這個 Memento，會比設計複雜的反向操作更簡單可靠。
2.  **需要保存快照供跳轉時**：
    *   如果系統需要支援「跳轉到任何歷史版本」的功能（而不僅僅是逐級 Undo/Redo），那麼在關鍵時間點保存 Receiver 的 Memento 快照，可以讓用戶直接選擇一個快照進行恢復。
3.  **效能考量**：
    *   對於某些編輯器，操作歷史可能非常長。如果每次 `undo()` 或 `redo()` 都需要重新執行所有之前的 Command，可能會導致效能瓶頸。
    *   透過定期保存中間狀態的 Memento，可以將歷史操作縮短，提高 Undo/Redo 的響應速度。

#### **Memento 結構建議：**

文件建議為兩種編輯器設計不同的狀態快照結構：

*   **文字編輯器 Memento (例如 `TextDocumentMemento`)**：
    *   應保存當前的**文字內容**。
    *   應保存**游標位置**。
    *   應保存**各區段的樣式資訊**（例如粗體、斜體、底線應用在哪些文字範圍）。
    這個 Memento 將包含一個 `TextDocument` 物件恢復所需的所有資訊。

*   **畫布編輯器 Memento (例如 `CanvasMemento`)**：
    *   應保存**畫布上所有圖形物件的完整列表**（包括它們的類型、位置、大小、顏色等所有屬性）。
    *   應保存**目前選取的圖形 ID**，以便恢復時能維持用戶的選取狀態。
    這個 Memento 將包含一個 `Canvas` 物件恢復所需的所有資訊。

---

### **類別架構圖中的模式關係**

文件提供的類別架構圖清晰地展示了這兩個模式在「Foundation Only Layer」中的互動：

*   **`CommandHistory`** 位於頂部，它管理著一系列的 `Command` 物件。
*   **`<<protocol>> Command`** 定義了命令的通用介面，具體的命令（例如 `InsertTextCommand`, `AddShapeCommand`）都遵循這個協議。
*   **具體 Command** 物件（如 `InsertTextCommand`）會持有其操作對象，即**接收者**（`TextDocument` 或 `Canvas`）的引用。
*   **Memento** 物件雖然沒有直接出現在圖中，但它會在**接收者**內部被創建（`originator` 角色）並保存其狀態，而 **Command** 物件在需要回溯狀態時，可能會利用 Memento 來恢復接收者的狀態。或者，`CommandHistory` 也可能直接管理 Memento 快照，用於「跳轉到特定歷史版本」的功能。

總體而言，Command Pattern 負責將操作物件化和可撤銷化，而 Memento Pattern 則提供了一種可靠且非侵入性地保存和恢復物件狀態的機制，兩者共同為複雜系統的 Undo/Redo 功能奠定了堅實的基礎，同時嚴格遵守了架構分層（Foundation Only Layer）的設計限制。