//
//  BasePopupHandler.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
import UIKit

/// Base class for all popup handlers implementing Chain of Responsibility pattern
open class BasePopupHandler: PopupHandler {
    public weak var next: PopupHandler?
    public let popupType: PopupType
    private var context: PopupContext?

    public init(popupType: PopupType) {
        self.popupType = popupType
    }

    /// Template method that subclasses must override to implement popup logic
    /// - Parameter context: The execution context
    /// - Returns: Result indicating whether to show, skip, or terminate
    open func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        fatalError("Subclasses must implement handle(context:)")
    }
    
    // MARK: - Protected Methods
    
    /// Sets the execution context. Called by subclasses at the beginning of handle().
    /// - Parameter context: The execution context
    internal func setContext(_ context: PopupContext) {
        self.context = context
    }

    /// Default implementation continues to next handler
    public func onPopupDismissed() {
        guard let context = context else { return }
        
        context.logger.log("Popup dismissed: \(popupType.displayName)", level: .info)

        // Continue to next handler
        if let next = next {
            let delay = context.popupTransitionDelay
            if delay > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    _ = next.handle(context: context)
                }
            } else {
                _ = next.handle(context: context)
            }
        } else {
            // Chain completed
            context.logger.log("Popup chain completed", level: .info)
        }
    }

    // MARK: - Protected Helper Methods

    /// Checks if popup should be shown based on state
    /// - Returns: True if should show, false otherwise
    internal func shouldShow() -> Bool {
        guard let context = context else { return false }
        
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

    /// Presents the popup, marks it as shown, and continues the chain on dismissal.
    /// - Returns: A result indicating the popup was shown.
    internal func showAndContinue() -> Result<PopupHandleResult, PopupError> {
        guard let context = context else { 
            return .success(.chainTerminated)
        }
        
        context.logger.log("Will show popup and continue chain: \(popupType.displayName)", level: .info)

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
            // Optionally, return an error to halt the chain
            // return .failure(.stateUpdateFailed(error))
        }

        // Present popup via presenter
        if let presenter = context.presenter {
            // In a real app, this would get the top view controller
            presenter.present(type: popupType, from: UIViewController()) { [weak self] in
                // When popup is dismissed, continue the chain
                self?.onPopupDismissed()
            }
        } else {
            // No presenter, so continue chain immediately (for testing)
            onPopupDismissed()
        }

        return .success(.shown(popupType))
    }

    /// Presents the popup, marks it as shown, and terminates the chain on dismissal.
    /// - Returns: A result indicating the chain should terminate.
    internal func showAndTerminate() -> Result<PopupHandleResult, PopupError> {
        guard let context = context else { 
            return .success(.chainTerminated)
        }
        
        context.logger.log("Will show popup and terminate chain: \(popupType.displayName)", level: .info)
        
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
        
        // Present popup via presenter
        if let presenter = context.presenter {
            presenter.present(type: popupType, from: UIViewController()) { [weak self] in
                // When popup is dismissed, log termination
                guard let self = self, let context = self.context else { return }
                context.logger.log("Terminating chain after \(self.popupType.displayName) was dismissed.", level: .info)
            }
        }
        
        return .success(.chainTerminated)
    }

    /// Skips this popup and continues to next handler, returning the result of the subsequent handler.
    /// - Returns: The result from the next handler in the chain, or `.chainTerminated` if it's the end.
    internal func skip() -> Result<PopupHandleResult, PopupError> {
        guard let context = context else { 
            return .success(.chainTerminated)
        }
        
        context.logger.log("Skipping popup: \(popupType.displayName)", level: .debug)

        // Continue to the next handler and return its result directly.
        if let next = next {
            return next.handle(context: context)
        } else {
            // This is the end of the chain.
            context.logger.log("Chain terminated at the end.", level: .info)
            return .success(.chainTerminated)
        }
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
