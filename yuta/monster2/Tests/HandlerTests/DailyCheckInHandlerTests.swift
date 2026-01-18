import XCTest
@testable import PopupResponseChain

final class DailyCheckInHandlerTests: XCTestCase {
    
    private var sut: DailyCheckInHandler!
    
    override func setUp() {
        super.setUp()
        sut = DailyCheckInHandler()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testShouldHandle_WhenNotCheckedIn_ReturnsTrue() {
        // Given
        let context = UserContext(hasCheckedInToday: false)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testShouldHandle_WhenCheckedIn_ReturnsFalse() {
        // Given
        let context = UserContext(hasCheckedInToday: true)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertFalse(result)
    }
}
