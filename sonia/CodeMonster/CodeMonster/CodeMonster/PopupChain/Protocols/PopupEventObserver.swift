//
//  PopupEventObserver.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation

/// Observes popup chain lifecycle events.
/// Implementations receive notifications for UI updates, analytics, etc.
public protocol PopupEventObserver: AnyObject {
    /// Called when a popup event is published.
    /// - Parameter event: The event that occurred.
    func popupChain(didPublish event: PopupEvent)
}
