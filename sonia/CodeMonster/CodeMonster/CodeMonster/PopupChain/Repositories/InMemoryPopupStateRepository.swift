import Foundation

/// In-memory implementation of PopupStateRepository for testing and development
public class InMemoryPopupStateRepository: PopupStateRepository {
    private var states: [String: [PopupType: PopupState]] = [:]
    private let queue = DispatchQueue(label: "com.popupchain.repository", attributes: .concurrent)

    public init() {}

    public func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError> {
        var result: PopupState?

        queue.sync {
            result = states[memberId]?[type]
        }

        if let state = result {
            return .success(state)
        }

        // Return default state if not found
        let defaultState = PopupState(type: type)
        return .success(defaultState)
    }

    public func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError> {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self.states[memberId] == nil {
                self.states[memberId] = [:]
            }
            self.states[memberId]?[state.type] = state
        }
        return .success(())
    }

    public func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError> {
        var currentState: PopupState?

        queue.sync {
            currentState = states[memberId]?[type]
        }

        let newState = PopupState(
            type: type,
            hasShown: true,
            lastShownDate: Date(),
            showCount: (currentState?.showCount ?? 0) + 1
        )

        return updateState(newState, memberId: memberId)
    }

    public func resetUser(memberId: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.states[memberId] = nil
        }
    }

    public func resetAll() {
        queue.async(flags: .barrier) { [weak self] in
            self?.states.removeAll()
        }
    }
}
