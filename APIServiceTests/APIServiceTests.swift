//
//  APIServiceTests.swift
//  APIServiceTests
//
//  Created by Péter Sanyó on 05.12.23.
//

@testable import BitcoinTracker
import XCTest

final class APIServiceTests: XCTestCase {
    /// Tests the successful retrieval of the current Bitcoin price from the CryptoCompare API.
    /// This test verifies that the `fetchCurrentBitcoinPrice` function of the `CryptoCompareService` successfully fetches and returns a Bitcoin price greater than 20,000, which is a realistic expectation for the Bitcoin to Euro exchange rate at the time of writing.
    /// **It uses an actual network call to the API, which means the test's success is dependent on network availability and the API's response.**
    func testFetchCurrentBitcoinPrice_Success() {
        // Arrange
        let service = CryptoCompareService()
        let expectation = self.expectation(description: "Fetch Bitcoin Price")

        // Act
        service.fetchCurrentBitcoinPrice(currency: .eur) { result in
            if case .success(let rate) = result {
                // Assert
                XCTAssertTrue(rate > 20_000, "Fetched rate should be greater than 20,000.")
                expectation.fulfill()
            }
        }

        // allowing time for the network response.
        waitForExpectations(timeout: 4, handler: nil)
    }
}
