import XCTest
@testable import PopupResponseChain

final class PredictionResultHandlerTests: XCTestCase {
    
    private var sut: PredictionResultHandler!
    
    override func setUp() {
        super.setUp()
        sut = PredictionResultHandler()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testShouldHandle_WhenHasResult_ReturnsTrue() {
        // Given
        let context = UserContext(hasPredictionResult: true)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testShouldHandle_WhenNoResult_ReturnsFalse() {
        // Given
        let context = UserContext(hasPredictionResult: false)
        
        // When
        let result = sut.shouldHandle(context)
        
        // Then
        XCTAssertFalse(result)
    }
}
