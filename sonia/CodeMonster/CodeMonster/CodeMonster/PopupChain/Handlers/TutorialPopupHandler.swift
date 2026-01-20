import Foundation
import UIKit

/// Handler for Tutorial popup - displays once for new users and terminates the chain
public class TutorialPopupHandler: BasePopupHandler {
    
    public init() {
        super.init(popupType: .tutorial)
    }
    
    public override func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        context.logger.log("Checking tutorial popup condition", level: .debug)
        
        // Check if user has already seen tutorial
        guard shouldShow(context: context) else {
            return skip(context: context)
        }
        
        // Tutorial should show - present it
        context.logger.log("Tutorial will be shown - chain will terminate after", level: .info)
        
        // Check if presenter available
        guard let presenter = context.presenter else {
            context.logger.log("No presenter available for tutorial", level: .warning)
            // Even without presenter, mark as shown and terminate
            _ = context.stateRepository.markAsShown(
                type: popupType,
                memberId: context.userInfo.memberId
            )
            return .success(.chainTerminated)
        }
        
        // Mark as shown
        let markResult = context.stateRepository.markAsShown(
            type: popupType,
            memberId: context.userInfo.memberId
        )
        
        if case .failure(let error) = markResult {
            context.logger.log(
                "Failed to mark tutorial as shown: \(error.localizedDescription)",
                level: .error
            )
        }
        
        // Present the popup
        // In real scenario, this would be called with actual view controller
        // For now we simulate presentation
        // The presenter.present() should be called by PopupChainManager with actual VC
        
        // Tutorial always terminates the chain after display
        return .success(.chainTerminated)
    }
    
    public override func onPopupDismissed(context: PopupContext) {
        context.logger.log("Tutorial dismissed - chain terminated", level: .info)
        // Tutorial terminates chain, so don't continue to next handler
        // Chain completed
    }
}
