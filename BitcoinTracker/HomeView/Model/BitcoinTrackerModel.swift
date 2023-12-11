//
//  BitcoinTrackerModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import CoreData
import Foundation

/// Model for handling the logic of cryptocurrency data retrieval and storage.
struct BitcoinTrackerModel {
    private let apiService: APIService
    private let coreDataService: CoreDataService
    
    init(apiService: APIService, coreDataService: CoreDataService) {
        self.apiService = apiService
        self.coreDataService = coreDataService
    }
    
    // MARK: - Current Bitcoin Price
        
    /// Fetches the current Bitcoin price for a given currency and returns the result via a completion handler.
    /// - Parameters:
    ///   - currency: The currency for which to fetch the Bitcoin price.
    ///   - completion: A completion handler that either provides the fetched price as a `Double` or an error.
    func fetchCurrentBitcoinPrice(currency: ExchangeCurrency, completion: @escaping (Result<Double, Error>) -> Void) {
        apiService.fetchCurrentBitcoinPrice(currency: currency) { result in
            switch result {
            case .success(let price):
                // Process the price, if needed
                completion(.success(price))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Historical Data
    
    /// Asynchronously fetches historical Bitcoin data for a given currency.
       /// - Parameter currency: The currency symbol (e.g., USD, EUR) to convert Bitcoin data into.
       /// - Returns: An array of `HistoricalRate` data representing daily Bitcoin values.
       /// - Throws: An error if the network request fails or data parsing fails.
    func fetchHistoricalBitcoinData(currency: ExchangeCurrency) async throws -> [HistoricalRate] {
        do {
            let historicalData = try await apiService.fetchHistoricalBitcoinData(currency: currency)
            return historicalData
        } catch {
            throw error // errors are being catched in HomeViewModel
        }
    }
    
    

    // MARK: - Helper Functions
    
    func replaceHistoricalRates(rates: [HistoricalRate], for currency: ExchangeCurrency) {
        coreDataService.replaceHistoricalRates(rates: rates, for: currency)
    }
    
    // MARK: - Debugging
    
    /// Prints all stored historical rates to the console for debugging purposes.
    func printAllStoredHistoricRates() {
        coreDataService.printAllStoredHistoricalRates()
    }
}
