import XCTest
@testable import CodeMonster

/// Spy implementation of PopupEventObserver for testing
public class SpyPopupEventObserver: PopupEventObserver {
    public var receivedEvents: [PopupEvent] = []
    public var eventTimestamps: [Date] = []
    public var onEventReceived: ((PopupEvent) -> Void)?

    public init() {}

    public func popupChain(didPublish event: PopupEvent) {
        receivedEvents.append(event)
        eventTimestamps.append(Date())
        onEventReceived?(event)
    }

    // MARK: - Test Helpers

    public func hasReceived(_ event: PopupEvent) -> Bool {
        receivedEvents.contains(event)
    }

    public func clear() {
        receivedEvents.removeAll()
        eventTimestamps.removeAll()
    }

    public func eventCount(for popupType: PopupType) -> Int {
        receivedEvents.filter { event in
            switch event {
            case .popupWillShow(let type),
                 .popupDidShow(let type),
                 .popupWillDismiss(let type),
                 .popupDidDismiss(let type):
                return type == popupType
            case .chainCompleted:
                return false
            }
        }.count
    }
}
