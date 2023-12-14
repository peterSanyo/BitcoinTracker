//
//  StoredHistoricalRate+CoreDataProperties.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 11.12.23.
//
//

import Foundation
import CoreData


extension StoredHistoricalRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredHistoricalRate> {
        return NSFetchRequest<StoredHistoricalRate>(entityName: "StoredHistoricalRate")
    }

    @NSManaged public var close: Double
    @NSManaged public var high: Double
    @NSManaged public var lastUpdate: Date
    @NSManaged public var low: Double
    @NSManaged public var open: Double
    @NSManaged public var time: Int32
    @NSManaged public var volumefrom: Double
    @NSManaged public var volumeto: Double
    @NSManaged public var currency: String
    
    // MARK: - Computed Properties

    /// Formats the unix timestamp into a readable date string (dd.MM.yy).
    internal var dateOfTimestamp: String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }

    /// Calculates the daily percentage change from open to close values.
    internal var dailyChangePercentage: Double {
        guard open != 0 else { return 0.0 }
        let change = close - open
        return (change / open) * 100
    }
}

extension StoredHistoricalRate : Identifiable {

}
