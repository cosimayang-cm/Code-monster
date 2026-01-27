import SwiftUI
import UndoRedoSystem

/// TextEditorView - Interactive text editor with undo/redo support
///
/// Features:
/// - Multi-line text editing
/// - Undo/Redo buttons with state management
/// - Style buttons (Bold, Italic, Underline)
/// - Real-time text synchronization
///
/// Architecture:
/// - Uses @StateObject to manage ViewModel lifecycle
/// - Binds to ViewModel @Published properties
/// - Uses Combine for reactive updates
struct TextEditorView: View {
    // MARK: - State

    @StateObject private var viewModel = TextEditorViewModel()
    @State private var localText: String = ""
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Toolbar
                toolbarView
                    .padding()
                    .background(SwiftUI.Color.gray.opacity(0.1))

                Divider()

                // Text Editor
                textEditorView
                    .padding()
            }
            .navigationTitle("Text Editor")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear {
            localText = viewModel.text
        }
    }

    // MARK: - Subviews

    /// Toolbar with undo/redo and style buttons
    private var toolbarView: some View {
        VStack(spacing: 12) {
            // Undo/Redo row
            HStack {
                Button(action: {
                    viewModel.undo()
                    localText = viewModel.text
                }) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .font(.system(size: 14))
                }
                .disabled(!viewModel.canUndo)

                Button(action: {
                    viewModel.redo()
                    localText = viewModel.text
                }) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                        .font(.system(size: 14))
                }
                .disabled(!viewModel.canRedo)

                Spacer()
            }

            // Style buttons row
            HStack {
                Button(action: applyBold) {
                    Image(systemName: "bold")
                        .font(.system(size: 16))
                        .frame(width: 32, height: 32)
                        .background(SwiftUI.Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }

                Button(action: applyItalic) {
                    Image(systemName: "italic")
                        .font(.system(size: 16))
                        .frame(width: 32, height: 32)
                        .background(SwiftUI.Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }

                Button(action: applyUnderline) {
                    Image(systemName: "underline")
                        .font(.system(size: 16))
                        .frame(width: 32, height: 32)
                        .background(SwiftUI.Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }

                Spacer()

                Text("Selection: \(selectedRange.location)-\(selectedRange.location + selectedRange.length)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    /// Multi-line text editor
    private var textEditorView: some View {
        TextEditor(text: $localText)
            .font(.body)
            .disableAutocorrection(false)
            .onChange(of: localText) { [oldText = localText] newValue in
                handleTextChange(oldValue: oldText, newValue: newValue)
            }
            .onChange(of: viewModel.text) { newValue in
                // Sync from ViewModel to UI (after undo/redo)
                if localText != newValue {
                    localText = newValue
                }
            }
    }

    // MARK: - Actions

    /// Handles text changes from user input
    private func handleTextChange(oldValue: String, newValue: String) {
        // Skip if change came from ViewModel (undo/redo)
        guard oldValue == viewModel.text else { return }

        // Calculate diff and apply command
        if newValue.count > oldValue.count {
            // Insertion
            let insertionPoint = findInsertionPoint(oldValue: oldValue, newValue: newValue)
            let insertedText = String(newValue.dropFirst(insertionPoint).prefix(newValue.count - oldValue.count))
            viewModel.insert(insertedText, at: insertionPoint)
            selectedRange = NSRange(location: insertionPoint + insertedText.count, length: 0)
        } else if newValue.count < oldValue.count {
            // Deletion
            let deletionPoint = findDeletionPoint(oldValue: oldValue, newValue: newValue)
            let deletedLength = oldValue.count - newValue.count
            viewModel.delete(in: NSRange(location: deletionPoint, length: deletedLength))
            selectedRange = NSRange(location: deletionPoint, length: 0)
        }
        // Note: Replacement is handled as delete + insert
    }

    /// Applies bold style to selected range
    private func applyBold() {
        guard selectedRange.length > 0 else { return }
        viewModel.applyBold(in: selectedRange)
    }

    /// Applies italic style to selected range
    private func applyItalic() {
        guard selectedRange.length > 0 else { return }
        viewModel.applyItalic(in: selectedRange)
    }

    /// Applies underline style to selected range
    private func applyUnderline() {
        guard selectedRange.length > 0 else { return }
        viewModel.applyUnderline(in: selectedRange)
    }

    // MARK: - Helpers

    /// Finds insertion point by comparing old and new strings
    private func findInsertionPoint(oldValue: String, newValue: String) -> Int {
        let minLength = min(oldValue.count, newValue.count)
        for i in 0..<minLength {
            let oldIndex = oldValue.index(oldValue.startIndex, offsetBy: i)
            let newIndex = newValue.index(newValue.startIndex, offsetBy: i)
            if oldValue[oldIndex] != newValue[newIndex] {
                return i
            }
        }
        return minLength
    }

    /// Finds deletion point by comparing old and new strings
    private func findDeletionPoint(oldValue: String, newValue: String) -> Int {
        let minLength = min(oldValue.count, newValue.count)
        for i in 0..<minLength {
            let oldIndex = oldValue.index(oldValue.startIndex, offsetBy: i)
            let newIndex = newValue.index(newValue.startIndex, offsetBy: i)
            if oldValue[oldIndex] != newValue[newIndex] {
                return i
            }
        }
        return minLength
    }
}

#Preview {
    TextEditorView()
}
