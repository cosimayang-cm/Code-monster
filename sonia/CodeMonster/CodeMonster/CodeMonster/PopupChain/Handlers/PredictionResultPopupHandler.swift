//
//  PredictionResultPopupHandler.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
import UIKit

/// Handler for Prediction Result popup
/// Shows when user has prediction results available (hasPredictionResult == true)
/// Resets when new result is available
public class PredictionResultPopupHandler: BasePopupHandler {
    
    public init() {
        super.init(popupType: .predictionResult)
    }
    
    public override func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        setContext(context)
        context.logger.log("Checking prediction result popup condition", level: .debug)
        
        // Check if user has prediction result available
        guard context.userInfo.hasPredictionResult else {
            context.logger.log("No prediction result available, skipping", level: .debug)
            return skip()
        }
        
        // If has result, always show (resets on new result)
        context.logger.log("Prediction result will be shown", level: .info)
        
        return showAndContinue()
    }
}
