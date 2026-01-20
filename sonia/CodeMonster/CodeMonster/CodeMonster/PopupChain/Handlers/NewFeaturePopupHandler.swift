//
//  NewFeaturePopupHandler.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
import UIKit

/// Handler for New Feature announcement popup
/// Mutually exclusive with Interstitial Ad
public class NewFeaturePopupHandler: BasePopupHandler {
    
    public init() {
        super.init(popupType: .newFeature)
    }
    
    public override func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        setContext(context)
        context.logger.log("Checking new feature popup condition", level: .debug)
        
        // Check UserInfo first - if already seen, skip
        if context.userInfo.hasSeenNewFeature {
            context.logger.log("New feature already seen (UserInfo), skipping", level: .debug)
            return skip()
        }
        
        // Check ad exclusivity - NewFeature only shows if ad has ALREADY been shown (before this session)
        // Per FR-004: "Ad shown if hasSeenAd == false, otherwise New Feature shown if hasSeenNewFeature == false"
        // Use UserInfo.hasSeenAd (session start state) not repository state (changes during chain execution)
        if !context.userInfo.hasSeenAd {
            // Ad hasn't been shown before, so ad has priority this session
            context.logger.log("Skipping new feature - ad not shown yet (ad has priority)", level: .debug)
            return skip()
        }
        
        // Check if user has already seen new feature in repository
        guard super.shouldShow() else {
            return skip()
        }
        
        // Show the popup and continue the chain
        return showAndContinue()
    }
    

}
