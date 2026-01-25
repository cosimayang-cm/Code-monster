import SwiftUI

/// ContentView - Main container with TabView navigation
///
/// Provides tab-based navigation between:
/// - Text Editor (document with styles)
/// - Canvas Editor (shape drawing)
///
/// Uses SF Symbols for tab icons.
struct ContentView: View {
    var body: some View {
        TabView {
            TextEditorView()
                .tabItem {
                    Label("Text Editor", systemImage: "doc.text")
                }

            CanvasEditorView()
                .tabItem {
                    Label("Canvas", systemImage: "paintbrush")
                }
        }
    }
}

#Preview {
    ContentView()
}
