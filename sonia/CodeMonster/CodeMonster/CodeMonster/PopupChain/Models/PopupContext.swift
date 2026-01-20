import Foundation

/// Execution context for the popup chain
public struct PopupContext {
    public let userInfo: UserInfo
    public let stateRepository: PopupStateRepository
    public let presenter: PopupPresenter?
    public let logger: Logger

    public init(
        userInfo: UserInfo,
        stateRepository: PopupStateRepository,
        presenter: PopupPresenter?,
        logger: Logger
    ) {
        self.userInfo = userInfo
        self.stateRepository = stateRepository
        self.presenter = presenter
        self.logger = logger
    }
}
