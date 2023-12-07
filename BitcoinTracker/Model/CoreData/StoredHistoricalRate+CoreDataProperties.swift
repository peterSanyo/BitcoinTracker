//
//  StoredHistoricalRate+CoreDataProperties.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 07.12.23.
//
//

import CoreData
import Foundation

public extension StoredHistoricalRate {
    @nonobjc class func fetchRequest() -> NSFetchRequest<StoredHistoricalRate> {
        return NSFetchRequest<StoredHistoricalRate>(entityName: "StoredHistoricalRate")
    }

    @NSManaged var lastUpdate: Date
    @NSManaged var time: Int32
    @NSManaged var high: Double
    @NSManaged var low: Double
    @NSManaged var open: Double
    @NSManaged var close: Double
    @NSManaged var volumefrom: Double
    @NSManaged var volumeto: Double

    // MARK: - Computed Properties

    /// Computed property to convert unix timestamp time into `dd.mm.yy` format.
    internal var dateOfTimestamp: String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }

    /// Computed property to calculate the percentage change from open to close.
    internal var dailyChangePercentage: Double {
        guard open != 0 else { return 0.0 }
        let change = close - open
        return (change / open) * 100
    }

    /// Computed property to format last update date.
    internal var formattedUpdate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd.MM.yy, HH:mm"
        return dateFormatter.string(from: lastUpdate)
    }
}

extension StoredHistoricalRate: Identifiable {}
