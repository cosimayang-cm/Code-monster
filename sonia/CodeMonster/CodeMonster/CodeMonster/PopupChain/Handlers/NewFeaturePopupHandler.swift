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
        
        // Check ad exclusivity - if ad was shown, skip new feature
        let adStateResult = context.stateRepository.getState(
            for: .interstitialAd,
            memberId: context.userInfo.memberId
        )
        
        if case .success(let adState) = adStateResult, adState.hasShown {
            context.logger.log("Skipping new feature - ad already shown (exclusivity)", level: .debug)
            return skip()
        }
        
        // Check if user has already seen new feature
        guard super.shouldShow() else {
            return skip()
        }
        
        // Show the popup and continue the chain
        return showAndContinue()
    }
    

}
