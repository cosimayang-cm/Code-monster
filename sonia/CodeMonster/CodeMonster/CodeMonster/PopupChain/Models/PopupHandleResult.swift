//
//  PopupHandleResult.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation

/// Result of a handler's decision.
public enum PopupHandleResult: Equatable {
    /// Popup was shown; wait for user to dismiss.
    case shown(PopupType)
    /// Popup was skipped; proceed to next handler immediately.
    case skipped
    /// Chain was terminated; stop processing. (Tutorial only)
    case chainTerminated
}
