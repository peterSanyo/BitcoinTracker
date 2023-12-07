//
//  UserDefaults.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 06.12.23.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let lastRate = "lastBitcoinRate"
//        static let lastHistoricalData = "lastHistoricalData"
    }

    // Save last fetched Bitcoin rate
    func setLastBitcoinRate(_ rate: Double) {
        set(rate, forKey: Keys.lastRate)
    }

    // Retrieve cached Bitcoin rate
    func getLastBitcoinRate() -> Double? {
        return double(forKey: Keys.lastRate)
    }

//    // Save last fetched historical data
//    func setLastHistoricalData(_ data: [HistoricalRate]) {
//        if let encoded = try? JSONEncoder().encode(data) {
//            set(encoded, forKey: Keys.lastHistoricalData)
//        }
//    }
//
//    // Retrieve cached historical data
//    func getLastHistoricalData() -> [HistoricalRate]? {
//        if let data = data(forKey: Keys.lastHistoricalData) {
//            return try? JSONDecoder().decode([HistoricalRate].self, from: data)
//        }
//        return nil
//    }
}

