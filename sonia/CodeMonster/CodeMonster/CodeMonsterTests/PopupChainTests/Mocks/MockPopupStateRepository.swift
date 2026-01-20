import XCTest
@testable import CodeMonster

/// Mock implementation of PopupStateRepository for testing
public class MockPopupStateRepository: PopupStateRepository {
    public var states: [String: [PopupType: PopupState]] = [:]
    public var shouldFailRead = false
    public var shouldFailWrite = false
    public var getStateCalls: [(type: PopupType, memberId: String)] = []
    public var updateStateCalls: [(state: PopupState, memberId: String)] = []
    public var markAsShownCalls: [(type: PopupType, memberId: String)] = []

    public init() {}

    public func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError> {
        getStateCalls.append((type: type, memberId: memberId))

        if shouldFailRead {
            return .failure(.repositoryReadFailed(type))
        }

        if let state = states[memberId]?[type] {
            return .success(state)
        }

        // Return default state if not found
        let defaultState = PopupState(type: type)
        return .success(defaultState)
    }

    public func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError> {
        updateStateCalls.append((state: state, memberId: memberId))

        if shouldFailWrite {
            return .failure(.repositoryWriteFailed(state.type))
        }

        if states[memberId] == nil {
            states[memberId] = [:]
        }
        states[memberId]?[state.type] = state
        return .success(())
    }

    public func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError> {
        markAsShownCalls.append((type: type, memberId: memberId))

        if shouldFailWrite {
            return .failure(.repositoryWriteFailed(type))
        }

        let newState = PopupState(
            type: type,
            hasShown: true,
            lastShownDate: Date(),
            showCount: (states[memberId]?[type]?.showCount ?? 0) + 1
        )

        return updateState(newState, memberId: memberId)
    }

    public func resetUser(memberId: String) {
        states[memberId] = nil
    }

    public func resetAll() {
        states.removeAll()
        getStateCalls.removeAll()
        updateStateCalls.removeAll()
        markAsShownCalls.removeAll()
    }

    // MARK: - Test Helpers

    public func setState(_ state: PopupState, for memberId: String) {
        if states[memberId] == nil {
            states[memberId] = [:]
        }
        states[memberId]?[state.type] = state
    }
}
