//
//  PopupChainManager.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
import UIKit

/// Manages the popup chain lifecycle and coordinates popup display
public class PopupChainManager {
    
    private let context: PopupContext
    private var handlerChain: PopupHandler?
    private var allHandlers: [PopupHandler] = [] // Holds strong reference to all handlers
    private var hasTriggered = false
    
    // MARK: - Initialization
    
    public init(
        userInfo: UserInfo,
        stateRepository: PopupStateRepository,
        presenter: PopupPresenter?,
        logger: Logger,
        popupTransitionDelay: TimeInterval = 0.4,
        handlers: [PopupHandler]? = nil
    ) {
        self.context = PopupContext(
            userInfo: userInfo,
            stateRepository: stateRepository,
            presenter: presenter,
            logger: logger,
            popupTransitionDelay: popupTransitionDelay
        )
        
        let handlersToBuild = handlers ?? PopupChainManager.defaultHandlers()
        buildHandlerChain(from: handlersToBuild)
    }
    
    // MARK: - Public API
    
    /// Provides the default chain of handlers.
    /// - Returns: An array of `PopupHandler` instances in default order.
    public static func defaultHandlers() -> [PopupHandler] {
        return [
            TutorialPopupHandler(),
            InterstitialAdPopupHandler(),
            NewFeaturePopupHandler(),
            DailyCheckInPopupHandler(),
            PredictionResultPopupHandler()
        ]
    }
    
    /// Starts the popup chain from the first handler
    /// Only triggers once per session
    public func startPopupChain() {
        guard !hasTriggered else {
            context.logger.log("Popup chain already triggered this session", level: .debug)
            return
        }
        
        hasTriggered = true
        context.logger.log("Starting popup chain", level: .info)
        
        guard let firstHandler = handlerChain else {
            context.logger.log("No handlers in chain", level: .warning)
            return
        }
        
        // Start chain from first handler
        let result = firstHandler.handle(context: context)
        
        // Handle result
        switch result {
        case .success(.shown(let type)):
            context.logger.log("Popup shown: \(type.displayName)", level: .info)
            // Popup is displayed, wait for user to dismiss
            
        case .success(.skipped):
            context.logger.log("First handler skipped, chain continues", level: .debug)
            // Chain continues automatically via handler
            
        case .success(.chainTerminated):
            context.logger.log("Chain terminated by first handler", level: .info)
            
        case .failure(let error):
            context.logger.log("Error in first handler: \(error.localizedDescription)", level: .error)
        }
    }
    
    /// Returns true if the chain has been triggered this session
    public var hasTriggeredThisSession: Bool {
        hasTriggered
    }
    
    /// Resets the session flag - used for testing or simulating app restart
    public func resetSession() {
        hasTriggered = false
        context.logger.log("Session reset", level: .debug)
    }
    
    // MARK: - Private Methods
    
    private func buildHandlerChain(from handlers: [PopupHandler]) {
        allHandlers = handlers
        handlerChain = nil
        
        guard !handlers.isEmpty else {
            context.logger.log("Handler chain is empty.", level: .debug)
            return
        }
        
        // Link handlers in chain based on array order
        for i in 0..<(handlers.count - 1) {
            handlers[i].next = handlers[i + 1]
        }
        
        // Set the head of the chain
        handlerChain = handlers.first
        
        context.logger.log("Handler chain built with \(allHandlers.count) handler(s)", level: .debug)
    }
}
