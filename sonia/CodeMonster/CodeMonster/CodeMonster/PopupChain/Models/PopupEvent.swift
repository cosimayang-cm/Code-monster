//
//  PopupEvent.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation

/// Popup lifecycle events
public enum PopupEvent: Equatable {
    case popupWillShow(PopupType)
    case popupDidShow(PopupType)
    case popupWillDismiss(PopupType)
    case popupDidDismiss(PopupType)
    case chainCompleted
}
