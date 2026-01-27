import SwiftUI

/// UndoRedoDemoApp - SwiftUI App entry point
///
/// Demonstrates the UndoRedoSystem framework with interactive text and canvas editors.
///
/// Features:
/// - Text editor with undo/redo support
/// - Canvas editor with shape drawing
/// - Tab-based navigation
@main
struct UndoRedoDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
