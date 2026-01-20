//
//  PopupContext.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import Foundation

/// Execution context for the popup chain
public struct PopupContext {
    public let userInfo: UserInfo
    public let stateRepository: PopupStateRepository
    public let presenter: PopupPresenter?
    public let logger: Logger
    public let popupTransitionDelay: TimeInterval  // Delay between popup transitions (0 in tests, 0.4s in production)

    public init(
        userInfo: UserInfo,
        stateRepository: PopupStateRepository,
        presenter: PopupPresenter?,
        logger: Logger,
        popupTransitionDelay: TimeInterval = 0.4
    ) {
        self.userInfo = userInfo
        self.stateRepository = stateRepository
        self.presenter = presenter
        self.logger = logger
        self.popupTransitionDelay = popupTransitionDelay
    }
}
