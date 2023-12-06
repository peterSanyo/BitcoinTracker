//
//  APIServiceTests.swift
//  APIServiceTests
//
//  Created by Péter Sanyó on 05.12.23.
//

@testable import BitcoinTracker
import XCTest

class APIServiceTests: XCTestCase {
    /// Tests the successful retrieval of the current Bitcoin price from the CryptoCompare API.
    /// This test verifies that the `fetchCurrentBitcoinPrice` function of the `CryptoCompareService` successfully fetches and returns a Bitcoin price greater than 20,000, which is a realistic expectation for the Bitcoin to Euro exchange rate at the time of writing.
    /// **It uses an actual network call to the API, which means the test's success is dependent on network availability and the API's response.**
    func testFetchCurrentBitcoinPrice_Success() {
        // Arrange
        let model = BitcoinTrackerModel()
        let expectation = self.expectation(description: "Fetch Bitcoin Price")

        // Act
        model.fetchCurrentBitcoinPrice(currency: .eur) { result in
            if case .success(let rate) = result {
                // Assert
                XCTAssertTrue(rate > 20_000, "Fetched rate should be greater than 20,000.")
                expectation.fulfill()
            }
        }

        // allowing time for the network response.
        waitForExpectations(timeout: 4, handler: nil)
    }

    /// Tests the successful retrieval of the last 14 days of historical Bitcoin data using async/await.
    /// This test verifies that the `fetchHistoricalBitcoinData` function successfully fetches 14 days of data based on the object count and the covered timeframe of the timeStamps.
    func testFetchHistoricalBitcoinData_Success() async {
        // Arrange
        let model = BitcoinTrackerModel()

        do {
            // Act
            let data = try await model.fetchHistoricalBitcoinData(currency: .eur)

            // Assert
            XCTAssertEqual(data.count, 14, "Expected to receive exactly 14 days of historical data")
            if let firstDay = data.first, let lastDay = data.last {
                let timeDifference = lastDay.time - firstDay.time
                XCTAssertEqual(timeDifference, 13 * 24 * 60 * 60, "The data should cover exactly 14 days")
            }
        } catch {
            XCTFail("Fetching historical data failed with error: \(error)")
        }
    }
}
