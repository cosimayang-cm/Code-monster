# UndoRedoDemo - SwiftUI App

Interactive demonstration app for the UndoRedoSystem framework.

## Features

### Text Editor Tab
- Multi-line text editing with real-time synchronization
- Undo/Redo with visual button states
- Text styling (Bold, Italic, Underline) - Note: Styling is tracked but not visually rendered in TextEditor
- Selection range display

### Canvas Editor Tab
- Shape drawing tools: Rectangle, Circle, Line
- Color pickers for fill and stroke colors
- Drag gesture to create shapes
- Undo/Redo with descriptive button labels
- Shape count display
- Real-time shape rendering using SwiftUI Canvas

## How to Run

### Option 1: Xcode (Recommended for iOS Simulator)

1. Open the package in Xcode:
   ```bash
   open Package.swift
   ```

2. Select the `UndoRedoDemo` scheme

3. Select an iOS Simulator (e.g., iPhone 16 Pro)

4. Press `Cmd+R` to build and run

### Option 2: Command Line (macOS Desktop App)

```bash
swift run UndoRedoDemo
```

Note: This will open the app as a macOS desktop window. Some features may look different than on iOS.

### Option 3: Build Executable

```bash
swift build --target UndoRedoDemo
./.build/debug/UndoRedoDemo
```

## Usage

### Text Editor

1. Type in the text editor
2. Use Undo/Redo buttons to navigate edit history
3. Select text range (shown at bottom of toolbar)
4. Apply styles using Bold/Italic/Underline buttons
5. Observe how undo/redo restores previous states

### Canvas Editor

1. Select a shape tool (Rectangle, Circle, or Line)
2. Choose fill and stroke colors using color pickers
3. Drag on the canvas to create shapes:
   - **Rectangle**: Drag from one corner to the opposite corner
   - **Circle**: Drag from center outward (drag distance = radius)
   - **Line**: Drag from start point to end point
4. Use Undo/Redo to revert/restore shape operations
5. Shape count is displayed in the toolbar

## Architecture

- **MVVM Pattern**: Views observe ViewModels via Combine `@Published` properties
- **Command Pattern**: All operations are encapsulated as commands for undo/redo
- **Clean Separation**: Model layer uses Foundation-only types, View layer converts to SwiftUI/UIKit types
- **Reactive Updates**: UI automatically updates when ViewModel state changes

## Technologies

- SwiftUI 3.0+ (iOS 15.0+, macOS 12.0+)
- Combine for reactive bindings
- SwiftUI Canvas for efficient shape rendering
- SF Symbols 2.0+ for icons

## File Structure

```
Sources/UndoRedoDemo/
├── UndoRedoDemoApp.swift          # App entry point (@main)
├── Views/
│   ├── ContentView.swift          # TabView container
│   ├── TextEditorView.swift       # Text editor with undo/redo
│   └── CanvasEditorView.swift     # Canvas editor with shape tools
└── README.md                      # This file
```

## Notes

- Text styling commands are tracked in the undo/redo history but visual rendering is not implemented (SwiftUI TextEditor doesn't support attributed text)
- Canvas uses SwiftUI's Canvas API for efficient rendering of many shapes
- Color conversion between Foundation.Color and SwiftUI.Color is handled transparently
- Cross-platform support: iOS (recommended) and macOS (with some UI differences)

## See Also

- [User Stories](../../specs/004-undo-redo-system/spec.md) - Full requirements
- [UndoRedoSystem Framework](../UndoRedoSystem/) - Core framework implementation
- [Testing Guide](../../Tests/UndoRedoSystemTests/) - Unit tests
