//
//  CoreDataService.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 07.12.23.
//

import CoreData
import Foundation

class CoreDataService {
    private var moc: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.moc = context
    }
    
    func replaceHistoricalRates(rates: [HistoricalRate]) {
        
        // Update Timestamp
        let now = Date()
        updateLastUpdateTimestamp(now, in: moc)
        
        // If values have changed ... 
        if moc.hasChanges {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StoredHistoricalRate.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try moc.execute(deleteRequest)
                // After deleting, proceed to save new data
                saveNewHistoricalRates(rates)
            } catch {
                print("Error in deleting old records: \(error)")
            }
        }
    }
    
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

//    /// Saves a list of historical Bitcoin rates to Core Data.
//    /// - Parameter rates: An array of `HistoricalRate` objects to be saved.
//    func saveHistoricalRates(rates: [HistoricalRate]) {
//        if moc.hasChanges {
//            // Delete old data from Core Data before saving new data
//            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StoredHistoricalRate.fetchRequest()
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//            do {
//                try moc.execute(deleteRequest)
//            } catch {
//                print("Error in deleting old records: \(error)")
//            }
//
//            let now = Date()
//            for rateData in data {
//                let newRate = StoredHistoricalRate(context: moc)
//                newRate.lastUpdate = now
//                newRate.time = Int32(rateData.time)
//                newRate.high = rateData.high
//                newRate.low = rateData.low
//                newRate.open = rateData.open
//                newRate.close = rateData.close
//                newRate.volumefrom = rateData.volumefrom
//                newRate.volumeto = rateData.volumeto
//            }
//            try moc.save()
//
//    // Add more Core Data operations as needed
}
