import XCTest
@testable import PopupResponseChain

final class InterstitialAdHandlerTests: XCTestCase {
    
    private var sut: InterstitialAdHandler!
    
    override func setUp() {
        super.setUp()
        sut = InterstitialAdHandler()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testShouldHandle_WhenNotSeen_ReturnsTrue() {
        // Given
        let context = UserContext(hasSeenInterstitialAd: false)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testShouldHandle_WhenSeen_ReturnsFalse() {
        // Given
        let context = UserContext(hasSeenInterstitialAd: true)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertFalse(result)
    }
}
