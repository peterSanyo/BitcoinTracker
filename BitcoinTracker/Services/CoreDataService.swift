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
    
    // MARK: - Current Bitcoin Price
    
    /// Replaces the current historical rates with new data.
    ///
    /// updates the timeStamp of lastUpdate
    /// If fetched data has changed: calls `saveNewHistoricalRates`
    /// - Parameter rates: The new array of `HistoricalRate` objects to be saved.
    func replaceHistoricalRates(rates: [HistoricalRate]) {
        let now = Date()
        updateLastUpdateTimestamp(now, in: moc)
        
//        if moc.hasChanges {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StoredHistoricalRate.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try moc.execute(deleteRequest)
                // After deleting, proceeds to save new data
                saveNewHistoricalRates(rates)
            } catch {
                print("Error in deleting old records: \(error)")
            }
//        }
    }
    
    // MARK: - Historical Data
    
    /// Saves new historical rates into Core Data.
    /// - Parameter rates: The array of `HistoricalRate` objects to be saved.
    private func saveNewHistoricalRates(_ rates: [HistoricalRate]) {
        let now = Date()
        rates.forEach { rateData in
            let newRate = StoredHistoricalRate(context: moc)
            newRate.lastUpdate = now
            newRate.time = Int32(rateData.time)
            newRate.high = rateData.high
            newRate.low = rateData.low
            newRate.open = rateData.open
            newRate.close = rateData.close
            newRate.volumefrom = rateData.volumefrom
            newRate.volumeto = rateData.volumeto
        }
        do {
            try moc.save()
        } catch {
            print("Error saving historical rates: \(error)")
        }
    }
    
    /// Updates the  update timestamp for all `StoredHistoricalRate` records.
    /// - Parameters:
    ///   - date: The current date to set as the last update timestamp.
    ///   - context: The `NSManagedObjectContext` to perform the update.
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
}
