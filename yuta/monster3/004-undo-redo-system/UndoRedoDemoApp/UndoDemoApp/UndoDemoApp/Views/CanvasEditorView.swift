import SwiftUI

// Type aliases to avoid conflicts
typealias ModelColor = Color
typealias ModelShape = Shape
typealias ModelRectangle = Rectangle
typealias ModelCircle = Circle
typealias ModelLine = Line
typealias ModelPoint = Point
typealias ModelSize = Size

/// CanvasEditorView - Interactive canvas editor with shape drawing
///
/// Features:
/// - Shape tool selection (Rectangle, Circle, Line)
/// - Color picker for fill and stroke
/// - Drag gesture to create shapes
/// - Undo/Redo support
/// - Real-time shape rendering
///
/// Architecture:
/// - Uses @StateObject to manage ViewModel lifecycle
/// - Binds to ViewModel @Published properties
/// - Uses SwiftUI Canvas for efficient rendering
struct CanvasEditorView: View {
    // MARK: - State

    @StateObject private var viewModel: CanvasEditorViewModel
    @State private var selectedTool: ShapeTool = .rectangle
    @State private var fillColor: SwiftUI.Color = .blue.opacity(0.3)
    @State private var strokeColor: SwiftUI.Color = .blue
    @State private var dragStart: CGPoint?
    @State private var dragCurrent: CGPoint?

    // MARK: - Initialization

    init() {
        let canvas = Canvas()
        let commandHistory = CommandHistory()
        _viewModel = StateObject(wrappedValue: CanvasEditorViewModel(
            canvas: canvas,
            commandHistory: commandHistory
        ))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Toolbar
                toolbarView
                    .padding()
                    .background(SwiftUI.Color.gray.opacity(0.1))

                Divider()

                // Canvas
                canvasView
                    .background(SwiftUI.Color.white)
            }
            .navigationTitle("Canvas Editor")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    // MARK: - Subviews

    /// Toolbar with tool selection and undo/redo
    private var toolbarView: some View {
        VStack(spacing: 12) {
            // Undo/Redo row
            HStack {
                Button(action: viewModel.undo) {
                    Label(viewModel.undoButtonTitle, systemImage: "arrow.uturn.backward")
                        .font(.system(size: 14))
                }
                .disabled(!viewModel.canUndo)

                Button(action: viewModel.redo) {
                    Label(viewModel.redoButtonTitle, systemImage: "arrow.uturn.forward")
                        .font(.system(size: 14))
                }
                .disabled(!viewModel.canRedo)

                Spacer()

                Text("\(viewModel.shapes.count) shapes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Tool selection row
            HStack {
                toolButton(tool: .rectangle, icon: "rectangle")
                toolButton(tool: .circle, icon: "circle")
                toolButton(tool: .line, icon: "line.diagonal")

                Spacer()

                ColorPicker("Fill", selection: $fillColor)
                    .labelsHidden()
                    .frame(width: 40)

                ColorPicker("Stroke", selection: $strokeColor)
                    .labelsHidden()
                    .frame(width: 40)
            }
        }
    }

    /// Tool selection button
    private func toolButton(tool: ShapeTool, icon: String) -> some View {
        Button(action: { selectedTool = tool }) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .frame(width: 40, height: 32)
                .background(selectedTool == tool ? SwiftUI.Color.blue.opacity(0.2) : SwiftUI.Color.gray.opacity(0.2))
                .cornerRadius(6)
        }
    }

    /// Canvas view with shape rendering and gesture handling
    private var canvasView: some View {
        GeometryReader { geometry in
            ZStack {
                // Render existing shapes
                CanvasDrawingView(shapes: viewModel.shapes)

                // Render preview shape during drag
                if let start = dragStart, let current = dragCurrent {
                    previewShape(start: start, current: current)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if dragStart == nil {
                            dragStart = value.startLocation
                        }
                        dragCurrent = value.location
                    }
                    .onEnded { value in
                        if let start = dragStart {
                            createShape(start: start, end: value.location)
                        }
                        dragStart = nil
                        dragCurrent = nil
                    }
            )
        }
    }

    /// Preview shape during drag gesture
    @ViewBuilder
    private func previewShape(start: CGPoint, current: CGPoint) -> some View {
        switch selectedTool {
        case .rectangle:
            SwiftUI.Rectangle()
                .fill(fillColor)
                .overlay(
                    SwiftUI.Rectangle()
                        .stroke(strokeColor, lineWidth: 2)
                )
                .frame(
                    width: abs(current.x - start.x),
                    height: abs(current.y - start.y)
                )
                .position(
                    x: (start.x + current.x) / 2,
                    y: (start.y + current.y) / 2
                )

        case .circle:
            let radius = sqrt(pow(current.x - start.x, 2) + pow(current.y - start.y, 2))
            SwiftUI.Circle()
                .fill(fillColor)
                .overlay(
                    SwiftUI.Circle()
                        .stroke(strokeColor, lineWidth: 2)
                )
                .frame(width: radius * 2, height: radius * 2)
                .position(start)

        case .line:
            SwiftUI.Path { path in
                path.move(to: start)
                path.addLine(to: current)
            }
            .stroke(strokeColor, lineWidth: 2)
        }
    }

    // MARK: - Actions

    /// Creates a shape based on drag gesture
    private func createShape(start: CGPoint, end: CGPoint) {
        let modelFillColor = ModelColor(
            red: Double(fillColor.components.red),
            green: Double(fillColor.components.green),
            blue: Double(fillColor.components.blue),
            alpha: Double(fillColor.components.opacity)
        )
        let modelStrokeColor = ModelColor(
            red: Double(strokeColor.components.red),
            green: Double(strokeColor.components.green),
            blue: Double(strokeColor.components.blue),
            alpha: Double(strokeColor.components.opacity)
        )

        switch selectedTool {
        case .rectangle:
            let position = ModelPoint(
                x: Double(min(start.x, end.x)),
                y: Double(min(start.y, end.y))
            )
            let size = ModelSize(
                width: Double(abs(end.x - start.x)),
                height: Double(abs(end.y - start.y))
            )
            viewModel.addRectangle(
                at: position,
                size: size,
                fillColor: modelFillColor,
                strokeColor: modelStrokeColor
            )

        case .circle:
            let radius = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
            viewModel.addCircle(
                at: ModelPoint(x: Double(start.x), y: Double(start.y)),
                radius: Double(radius),
                fillColor: modelFillColor,
                strokeColor: modelStrokeColor
            )

        case .line:
            viewModel.addLine(
                from: ModelPoint(x: Double(start.x), y: Double(start.y)),
                to: ModelPoint(x: Double(end.x), y: Double(end.y)),
                strokeColor: modelStrokeColor
            )
        }
    }
}

/// Shape tool types
enum ShapeTool {
    case rectangle
    case circle
    case line
}

/// Canvas drawing subview - renders shapes efficiently
struct CanvasDrawingView: View {
    let shapes: [ModelShape]

    var body: some View {
        SwiftUI.Canvas { context, size in
            for shape in shapes {
                drawShape(shape, in: context)
            }
        }
    }

    /// Draws a single shape on the canvas
    private func drawShape(_ shape: ModelShape, in context: GraphicsContext) {
        if let rectangle = shape as? ModelRectangle {
            drawRectangle(rectangle, in: context)
        } else if let circle = shape as? ModelCircle {
            drawCircle(circle, in: context)
        } else if let line = shape as? ModelLine {
            drawLine(line, in: context)
        }
    }

    /// Draws a rectangle
    private func drawRectangle(_ rectangle: ModelRectangle, in context: GraphicsContext) {
        let rect = CGRect(
            x: rectangle.position.x,
            y: rectangle.position.y,
            width: rectangle.size.width,
            height: rectangle.size.height
        )

        if let fillColor = rectangle.fillColor {
            context.fill(
                Path(rect),
                with: .color(fillColor.swiftUIColor)
            )
        }

        if let strokeColor = rectangle.strokeColor {
            context.stroke(
                Path(rect),
                with: .color(strokeColor.swiftUIColor),
                lineWidth: 2
            )
        }
    }

    /// Draws a circle
    private func drawCircle(_ circle: ModelCircle, in context: GraphicsContext) {
        let rect = CGRect(
            x: circle.position.x - circle.radius,
            y: circle.position.y - circle.radius,
            width: circle.radius * 2,
            height: circle.radius * 2
        )

        if let fillColor = circle.fillColor {
            context.fill(
                Path(ellipseIn: rect),
                with: .color(fillColor.swiftUIColor)
            )
        }

        if let strokeColor = circle.strokeColor {
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(strokeColor.swiftUIColor),
                lineWidth: 2
            )
        }
    }

    /// Draws a line
    private func drawLine(_ line: ModelLine, in context: GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: line.position.x, y: line.position.y))
        path.addLine(to: CGPoint(x: line.endPoint.x, y: line.endPoint.y))

        if let strokeColor = line.strokeColor {
            context.stroke(
                path,
                with: .color(strokeColor.swiftUIColor),
                lineWidth: 2
            )
        }
    }
}

// MARK: - Extensions

/// Extension to convert model Color to SwiftUI Color
extension ModelColor {
    var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(
            red: red,
            green: green,
            blue: blue,
            opacity: alpha
        )
    }
}

/// Extension to extract color components from SwiftUI Color
extension SwiftUI.Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        uiColor.getRed(&r, green: &g, blue: &b, alpha: &o)
        return (r, g, b, o)
        #elseif canImport(AppKit)
        let nsColor = NSColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        nsColor.getRed(&r, green: &g, blue: &b, alpha: &o)
        return (r, g, b, o)
        #else
        return (1, 1, 1, 1)
        #endif
    }
}

#Preview {
    CanvasEditorView()
}
