import XCTest
@testable import PopupResponseChain

final class NewFeatureHandlerTests: XCTestCase {
    
    private var sut: NewFeatureHandler!
    
    override func setUp() {
        super.setUp()
        sut = NewFeatureHandler()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testShouldHandle_WhenNotSeen_ReturnsTrue() {
        // Given
        let context = UserContext(hasSeenNewFeature: false)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testShouldHandle_WhenSeen_ReturnsFalse() {
        // Given
        let context = UserContext(hasSeenNewFeature: true)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertFalse(result)
    }
}
