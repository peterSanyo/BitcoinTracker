//
//  BitcoinTrackerModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import Foundation

import CoreData
/// model for handling the logic of cryptocurrency data retrieval.
import Foundation

struct BitcoinTrackerModel {
    let apiService: APIService
    let coreDataService: CoreDataService

    init(apiService: APIService, coreDataService: CoreDataService) {
        self.apiService = apiService
        self.coreDataService = coreDataService
    }

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

    func fetchHistoricalBitcoinData(currency: ExchangeCurrency) async throws -> [HistoricalRate] {
        do {
            let historicalData = try await apiService.fetchHistoricalBitcoinData(currency: currency)
            return historicalData
        } catch {
            throw error
        }
    }
}

private func updateLastUpdateTimestamp(_ date: Date, in context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<StoredHistoricalRate> = StoredHistoricalRate.fetchRequest()
    do {
        let results = try context.fetch(fetchRequest)
        results.forEach { $0.lastUpdate = date }
        try context.save()
    } catch {
        print("Failed to update lastUpdate timestamp: \(error)")
    }
}
