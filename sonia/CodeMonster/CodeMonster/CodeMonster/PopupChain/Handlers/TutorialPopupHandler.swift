//
//  TutorialPopupHandler.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation
import UIKit

/// Handler for Tutorial popup - displays once for new users and terminates the chain
public class TutorialPopupHandler: BasePopupHandler {
    
    public init() {
        super.init(popupType: .tutorial)
    }
    
    public override func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        setContext(context)
        context.logger.log("Checking tutorial popup condition", level: .debug)
        
        // Check if user has already seen tutorial
        guard shouldShow() else {
            return skip()
        }
        
        // Show the popup and terminate the chain
        return showAndTerminate()
    }
}
