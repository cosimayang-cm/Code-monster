import Foundation

/// Base class for all popup handlers implementing Chain of Responsibility pattern
open class BasePopupHandler: PopupHandler {
    public weak var next: PopupHandler?
    public let popupType: PopupType

    public init(popupType: PopupType) {
        self.popupType = popupType
    }

    /// Template method that subclasses must override to implement popup logic
    /// - Parameter context: The execution context
    /// - Returns: Result indicating whether to show, skip, or terminate
    open func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        fatalError("Subclasses must implement handle(context:)")
    }

    /// Default implementation continues to next handler
    public func onPopupDismissed(context: PopupContext) {
        context.logger.log("Popup dismissed: \(popupType.displayName)", level: .info)

        // Continue to next handler
        if let next = next {
            handleNext(context: context, handler: next)
        } else {
            // Chain completed
            context.logger.log("Popup chain completed", level: .info)
        }
    }

    // MARK: - Protected Helper Methods

    /// Checks if popup should be shown based on state
    /// - Parameters:
    ///   - context: The execution context
    /// - Returns: True if should show, false otherwise
    internal func shouldShow(context: PopupContext) -> Bool {
        let stateResult = context.stateRepository.getState(
            for: popupType,
            memberId: context.userInfo.memberId
        )

        guard case .success(let state) = stateResult else {
            context.logger.log(
                "Failed to read state for \(popupType.rawValue), skipping",
                level: .warning
            )
            return false
        }

        // Check reset policy
        switch popupType.resetPolicy {
        case .permanent:
            return !state.hasShown

        case .daily:
            guard let lastShown = state.lastShownDate else {
                return true
            }
            return !Calendar.current.isDateInToday(lastShown)

        case .onNewResult:
            // This is handled by individual handlers
            return true
        }
    }

    /// Presents the popup and handles the result
    /// - Parameters:
    ///   - context: The execution context
    ///   - completion: Called after popup is dismissed
    internal func presentPopup(
        context: PopupContext,
        completion: @escaping () -> Void
    ) {
        guard let presenter = context.presenter else {
            context.logger.log(
                "No presenter available for \(popupType.rawValue)",
                level: .warning
            )
            completion()
            return
        }

        // Mark as shown before presenting
        let markResult = context.stateRepository.markAsShown(
            type: popupType,
            memberId: context.userInfo.memberId
        )

        if case .failure(let error) = markResult {
            context.logger.log(
                "Failed to mark \(popupType.rawValue) as shown: \(error.localizedDescription)",
                level: .error
            )
        }

        // Present popup - this will be implemented by UI layer
        context.logger.log("Presenting popup: \(popupType.displayName)", level: .debug)
        completion()
    }

    /// Continues to next handler in the chain
    /// - Parameters:
    ///   - context: The execution context
    ///   - handler: The next handler
    internal func handleNext(context: PopupContext, handler: PopupHandler) {
        let result = handler.handle(context: context)

        switch result {
        case .success(.shown):
            // Next handler showed a popup, wait for dismissal
            context.logger.log(
                "Next handler showed popup: \(handler.popupType.displayName)",
                level: .debug
            )

        case .success(.skipped):
            // Next handler skipped, chain will continue automatically
            context.logger.log(
                "Next handler skipped: \(handler.popupType.displayName)",
                level: .debug
            )

        case .success(.chainTerminated):
            // Chain terminated
            context.logger.log("Chain terminated by handler", level: .info)

        case .failure(let error):
            // Error in next handler, but continue chain
            context.logger.log(
                "Error in next handler: \(error.localizedDescription)",
                level: .error
            )
        }
    }

    /// Skips this popup and continues to next handler
    /// - Parameter context: The execution context
    /// - Returns: Skipped result
    internal func skip(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        context.logger.log("Skipping popup: \(popupType.displayName)", level: .debug)

        // Continue to next handler immediately
        if let next = next {
            handleNext(context: context, handler: next)
        }

        return .success(.skipped)
    }
}

// MARK: - Protected Extension

extension BasePopupHandler {
    /// Checks if the current date is different day from the given date
    internal func isDifferentDay(from date: Date?) -> Bool {
        guard let date = date else { return true }
        return !Calendar.current.isDateInToday(date)
    }
}
