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
        popupTransitionDelay: TimeInterval = 0.4
    ) {
        self.context = PopupContext(
            userInfo: userInfo,
            stateRepository: stateRepository,
            presenter: presenter,
            logger: logger,
            popupTransitionDelay: popupTransitionDelay
        )
        
        buildHandlerChain()
    }
    
    // MARK: - Public API
    
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
    
    private func buildHandlerChain() {
        // Build full chain in priority order:
        // Tutorial (1) → InterstitialAd (2) → NewFeature (3) → DailyCheckIn (4) → PredictionResult (5)
        
        let tutorialHandler = TutorialPopupHandler()
        let adHandler = InterstitialAdPopupHandler()
        let featureHandler = NewFeaturePopupHandler()
        let checkInHandler = DailyCheckInPopupHandler()
        let predictionHandler = PredictionResultPopupHandler()
        
        // Link handlers in chain
        tutorialHandler.next = adHandler
        adHandler.next = featureHandler
        featureHandler.next = checkInHandler
        checkInHandler.next = predictionHandler
        
        handlerChain = tutorialHandler
        
        // Store all handlers in an array to maintain strong references
        allHandlers = [tutorialHandler, adHandler, featureHandler, checkInHandler, predictionHandler]
        
        context.logger.log("Handler chain built with \(allHandlers.count) handler(s)", level: .debug)
    }
}
