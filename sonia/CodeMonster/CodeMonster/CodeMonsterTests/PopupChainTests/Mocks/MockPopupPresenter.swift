import XCTest
import UIKit
@testable import CodeMonster

/// Mock implementation of PopupPresenter for testing
public class MockPopupPresenter: PopupPresenter {
    public var presentedPopups: [PopupType] = []
    public var dismissedPopups: [PopupType] = []
    public var presentCalls: [(type: PopupType, viewController: UIViewController)] = []
    public var shouldFailPresent = false
    public var presentationDelay: TimeInterval = 0

    private var completionHandlers: [PopupType: () -> Void] = [:]

    public init() {}

    public var isPresenting: Bool {
        !presentedPopups.isEmpty
    }

    public var currentPopupType: PopupType? {
        presentedPopups.last
    }

    public func present(
        type: PopupType,
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        presentCalls.append((type: type, viewController: viewController))

        if shouldFailPresent {
            return
        }

        presentedPopups.append(type)
        completionHandlers[type] = completion

        // Auto-dismiss after delay for testing
        if presentationDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + presentationDelay) { [weak self] in
                self?.simulateUserDismissal(type: type)
            }
        }
    }

    public func dismiss(type: PopupType) {
        if let index = presentedPopups.firstIndex(of: type) {
            presentedPopups.remove(at: index)
            dismissedPopups.append(type)
            completionHandlers[type] = nil
        }
    }

    // MARK: - Test Helpers

    /// Simulates user tapping the dismiss button
    public func simulateUserDismissal(type: PopupType) {
        if let completion = completionHandlers[type] {
            dismiss(type: type)
            completion()
        }
    }

    public func reset() {
        presentedPopups.removeAll()
        dismissedPopups.removeAll()
        presentCalls.removeAll()
        completionHandlers.removeAll()
    }
}
