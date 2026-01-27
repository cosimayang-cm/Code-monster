#if canImport(UIKit)
import UIKit
import UndoRedoSystem

/// Example: How to use TextEditorViewController
///
/// This example demonstrates how to instantiate and use the TextEditorViewController
/// with proper dependency injection following PAGEs Framework patterns.
class TextEditorExampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create ViewModel with initial text
        let viewModel = TextEditorViewModel(initialText: "Hello, World!")

        // Create ViewController with dependency injection
        let textEditorVC = TextEditorViewController(viewModel: viewModel)

        // Add as child view controller
        addChild(textEditorVC)
        view.addSubview(textEditorVC.view)
        textEditorVC.didMove(toParent: self)

        // Setup constraints
        textEditorVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textEditorVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            textEditorVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textEditorVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textEditorVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

/// Example: How to use CanvasEditorViewController
///
/// This example demonstrates how to instantiate and use the CanvasEditorViewController
/// with proper dependency injection following PAGEs Framework patterns.
class CanvasEditorExampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create dependencies
        let canvas = Canvas()
        let commandHistory = CommandHistory()

        // Create ViewModel with dependency injection
        let viewModel = CanvasEditorViewModel(
            canvas: canvas,
            commandHistory: commandHistory
        )

        // Add some initial shapes
        viewModel.addRectangle(
            at: Point(x: 50, y: 50),
            size: Size(width: 100, height: 80),
            fillColor: .blue,
            strokeColor: .black
        )

        viewModel.addCircle(
            at: Point(x: 200, y: 150),
            radius: 50,
            fillColor: .red,
            strokeColor: .black
        )

        // Create ViewController with dependency injection
        let canvasEditorVC = CanvasEditorViewController(viewModel: viewModel)

        // Add as child view controller
        addChild(canvasEditorVC)
        view.addSubview(canvasEditorVC.view)
        canvasEditorVC.didMove(toParent: self)

        // Setup constraints
        canvasEditorVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasEditorVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            canvasEditorVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasEditorVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasEditorVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

/// Example: TabBarController combining both editors
///
/// This example shows how to present both editors in a tab bar interface,
/// demonstrating complete separation and independent operation.
class EditorTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create Text Editor Tab
        let textViewModel = TextEditorViewModel()
        let textEditorVC = TextEditorViewController(viewModel: textViewModel)
        textEditorVC.tabBarItem = UITabBarItem(
            title: "文字編輯器",
            image: UIImage(systemName: "doc.text"),
            selectedImage: nil
        )

        // Create Canvas Editor Tab
        let canvas = Canvas()
        let commandHistory = CommandHistory()
        let canvasViewModel = CanvasEditorViewModel(
            canvas: canvas,
            commandHistory: commandHistory
        )
        let canvasEditorVC = CanvasEditorViewController(viewModel: canvasViewModel)
        canvasEditorVC.tabBarItem = UITabBarItem(
            title: "畫布編輯器",
            image: UIImage(systemName: "paintbrush"),
            selectedImage: nil
        )

        // Setup tab bar
        viewControllers = [
            UINavigationController(rootViewController: textEditorVC),
            UINavigationController(rootViewController: canvasEditorVC)
        ]
    }
}

// MARK: - App Integration Example

/// Example: How to integrate into a UIKit app
///
/// In your SceneDelegate or AppDelegate:
///
/// ```swift
/// func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
///     guard let windowScene = (scene as? UIWindowScene) else { return }
///
///     let window = UIWindow(windowScene: windowScene)
///     window.rootViewController = EditorTabBarController()
///     window.makeKeyAndVisible()
///     self.window = window
/// }
/// ```

// MARK: - Testing Example

/// Example: How to test ViewControllers with Combine
///
/// ```swift
/// import XCTest
/// import Combine
/// @testable import UndoRedoSystem
///
/// final class TextEditorViewControllerTests: XCTestCase {
///     var sut: TextEditorViewController!
///     var viewModel: TextEditorViewModel!
///     var cancellables: Set<AnyCancellable>!
///
///     override func setUp() {
///         super.setUp()
///         viewModel = TextEditorViewModel()
///         sut = TextEditorViewController(viewModel: viewModel)
///         cancellables = Set<AnyCancellable>()
///
///         // Load view hierarchy
///         _ = sut.view
///     }
///
///     func testWhenInsertTextThenUIUpdates() {
///         // Given
///         let expectation = expectation(description: "Text updated")
///         var receivedText: String?
///
///         viewModel.$text
///             .dropFirst() // Skip initial value
///             .sink { text in
///                 receivedText = text
///                 expectation.fulfill()
///             }
///             .store(in: &cancellables)
///
///         // When
///         viewModel.insert("Hello", at: 0)
///
///         // Then
///         wait(for: [expectation], timeout: 1.0)
///         XCTAssertEqual(receivedText, "Hello")
///     }
/// }
/// ```
#endif
