//
//  PopupError.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation

/// Popup operation errors
public enum PopupError: Error, Equatable {
    case repositoryReadFailed(PopupType)
    case repositoryWriteFailed(PopupType)
    case presenterCreationFailed
    case invalidState(String)

    public var localizedDescription: String {
        switch self {
        case .repositoryReadFailed(let type):
            return "Failed to read state for \(type.rawValue)"
        case .repositoryWriteFailed(let type):
            return "Failed to write state for \(type.rawValue)"
        case .presenterCreationFailed:
            return "Failed to create popup presenter"
        case .invalidState(let message):
            return "Invalid state: \(message)"
        }
    }
}
