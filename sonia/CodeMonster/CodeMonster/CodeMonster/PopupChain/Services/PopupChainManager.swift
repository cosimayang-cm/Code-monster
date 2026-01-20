import Foundation
import UIKit

/// Manages the popup chain lifecycle and coordinates popup display
public class PopupChainManager {
    
    private let context: PopupContext
    private var handlerChain: PopupHandler?
    private var hasTriggered = false
    
    // MARK: - Initialization
    
    public init(
        userInfo: UserInfo,
        stateRepository: PopupStateRepository,
        presenter: PopupPresenter?,
        logger: Logger
    ) {
        self.context = PopupContext(
            userInfo: userInfo,
            stateRepository: stateRepository,
            presenter: presenter,
            logger: logger
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
        // Phase 3 (US1): Only tutorial handler
        // Phase 4 (US2): Will add full chain
        
        let tutorialHandler = TutorialPopupHandler()
        
        // For Phase 3, we only have tutorial handler
        handlerChain = tutorialHandler
        
        context.logger.log("Handler chain built with \(1) handler(s)", level: .debug)
    }
}
