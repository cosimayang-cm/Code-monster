//
//  InterstitialAdPopupHandler.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
import UIKit

/// Handler for Interstitial Ad popup
public class InterstitialAdPopupHandler: BasePopupHandler {
    
    public init() {
        super.init(popupType: .interstitialAd)
    }
    
    public override func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        setContext(context)
        context.logger.log("Checking interstitial ad popup condition", level: .debug)
        
        // Check UserInfo first
        if context.userInfo.hasSeenAd {
            context.logger.log("Ad already seen (UserInfo), skipping", level: .debug)
            return skip()
        }
        
        // Check if user has already seen ad in repository
        guard shouldShow() else {
            return skip()
        }
        
        // Show the popup and continue the chain
        return showAndContinue()
    }
}
