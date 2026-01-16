import UIKit

/// Execution context for the popup chain
struct PopupContext {
    let userInfo: UserInfo
    let stateRepository: PopupStateRepository
    let presenter: PopupPresenter?
    let logger: Logger

    init(
        userInfo: UserInfo,
        stateRepository: PopupStateRepository,
        presenter: PopupPresenter? = nil,
        logger: Logger
    ) {
        self.userInfo = userInfo
        self.stateRepository = stateRepository
        self.presenter = presenter
        self.logger = logger
    }
}
