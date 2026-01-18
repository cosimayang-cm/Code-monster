import XCTest
@testable import PopupResponseChain

final class TutorialHandlerTests: XCTestCase {
    
    private var sut: TutorialHandler!
    
    override func setUp() {
        super.setUp()
        sut = TutorialHandler()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testShouldHandle_WhenNotSeen_ReturnsTrue() {
        // Given
        let context = UserContext(hasSeenTutorial: false)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testShouldHandle_WhenSeen_ReturnsFalse() {
        // Given
        let context = UserContext(hasSeenTutorial: true)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertFalse(result)
    }
}
