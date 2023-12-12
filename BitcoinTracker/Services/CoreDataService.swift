//
//  CoreDataService.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 07.12.23.
//

import CoreData
import Foundation

/// Provides services for Core Data operations related to `StoredHistoricalRate`.
class CoreDataService {
    private var moc: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.moc = context
    }

    // MARK: - Replacing Historical Data

    /// Replaces the current historical rates with newly fetched  data.
    ///
    /// updates the timeStamp of lastUpdate
    /// If fetched data has changed: calls `saveNewHistoricalRates`
    /// - Parameter rates: The new array of `HistoricalRate` objects to be saved.
    func replaceHistoricalRates(rates: [HistoricalRate], for currency: ExchangeCurrency) {
        do {
            let existingTimestamps = try fetchExistingTimestamps(for: currency.currencyOption)
            let newTimestamps = Set(rates.map { Int32($0.time) })

            if existingTimestamps != newTimestamps {
                deleteHistoricalRates(for: currency.currencyOption)
                saveNewHistoricalRates(rates, for: currency)
            }
        } catch {
            print("Error in fetching existing timestamps: \(error)")
        }
    }

    // MARK: - Historical Data Methods

    private func fetchExistingTimestamps(for currencyOption: String) throws -> Set<Int32> {
        let fetchRequest = createFetchRequest(for: currencyOption)
        let existingRates = try moc.fetch(fetchRequest)
        return Set(existingRates.map { $0.time })
    }

    private func deleteHistoricalRates(for currencyOption: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = createFetchRequest(for: currencyOption) as! NSFetchRequest<NSFetchRequestResult>
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try moc.execute(deleteRequest)
        } catch {
            print("Error deleting historical rates for \(currencyOption): \(error)")
        }
    }

    /// Saves new historical rates into Core Data
    /// - Parameter rates: The array of `HistoricalRate` objects to be saved.
    func saveNewHistoricalRates(_ rates: [HistoricalRate], for currency: ExchangeCurrency) {
        rates.forEach { rateData in
            let newRate = StoredHistoricalRate(context: moc)
            newRate.time = Int32(rateData.time)
            newRate.high = rateData.high
            newRate.low = rateData.low
            newRate.open = rateData.open
            newRate.close = rateData.close
            newRate.volumefrom = rateData.volumefrom
            newRate.volumeto = rateData.volumeto
            newRate.lastUpdate = Date()
            newRate.currency = currency.currencyOption
        }

        do {
            try moc.save()
            printAllStoredHistoricalRates()
        } catch {
            print("Error saving historical rates: \(error)")
        }
    }

    // MARK: - Utility Methods

    private func createFetchRequest(for currencyOption: String) -> NSFetchRequest<StoredHistoricalRate> {
        let fetchRequest: NSFetchRequest<StoredHistoricalRate> = StoredHistoricalRate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currency == %@", currencyOption)
        return fetchRequest
    }

    // MARK: - Debugging:

    func printAllStoredHistoricalRates() {
        let fetchRequest: NSFetchRequest<StoredHistoricalRate> = StoredHistoricalRate.fetchRequest()
        do {
            let results = try moc.fetch(fetchRequest)
            results.forEach { print("\($0)") }
        } catch {
            print("Error fetching stored historical rates for debugging: \(error)")
        }
    }
}
