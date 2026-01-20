import XCTest
@testable import CodeMonster

/// Debug test to understand chain behavior
class DebugTest: XCTestCase {
    
    func testAdMarkAsShown() {
        // Setup
        let mockRepo = MockPopupStateRepository()
        let mockPresenter = MockPopupPresenter()
        let mockLogger = MockLogger()
        
        let returningUser = UserInfo.returningUser
        mockRepo.setState(
            PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: returningUser.memberId
        )
        
        let chainManager = PopupChainManager(
            userInfo: returningUser,
            stateRepository: mockRepo,
            presenter: mockPresenter,
            logger: mockLogger, popupTransitionDelay: 0
        )
        
        // Execute
        chainManager.startPopupChain()
        
        // Debug output
        print("\n=== DEBUG OUTPUT ===")
        print("All states:")
        for (memberId, states) in mockRepo.states {
            print("  Member \(memberId):")
            for (type, state) in states {
                print("    \(type.displayName): hasShown=\(state.hasShown), showCount=\(state.showCount)")
            }
        }
        
        print("\nmarkAsShown calls:")
        for call in mockRepo.markAsShownCalls {
            print("  \(call.type.displayName) for member \(call.memberId)")
        }
        
        print("\nLogger messages:")
        mockLogger.printLogs()
        print("=== END DEBUG ===\n")
        
        // Assertions
        let adState = mockRepo.states[returningUser.memberId]?[.interstitialAd]
        XCTAssertEqual(adState?.hasShown, true, "Ad should be marked as shown")
    }
}
