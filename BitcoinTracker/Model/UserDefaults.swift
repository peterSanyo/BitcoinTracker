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
    }

    func setLastBitcoinRate(_ rate: Double) {
        set(rate, forKey: Keys.lastRate)
    }

    func getLastBitcoinRate() -> Double? {
        return double(forKey: Keys.lastRate)
    }
}
