//
//  DailyCheckInPopupHandler.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
import UIKit

/// Handler for Daily Check-in popup
/// Resets daily - can show once per calendar day
public class DailyCheckInPopupHandler: BasePopupHandler {
    
    public init() {
        super.init(popupType: .dailyCheckIn)
    }
    
    public override func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        setContext(context)
        context.logger.log("Checking daily check-in popup condition", level: .debug)
        
        // Check if user has already checked in today
        guard shouldShow() else {
            return skip()
        }
        
        // Show the popup and continue the chain
        return showAndContinue()
    }
}
