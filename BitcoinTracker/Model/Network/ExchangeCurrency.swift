//
//  ExchangeCurrency.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import Foundation

/// Enum representing supported exchange currencies.
enum ExchangeCurrency: CaseIterable {
    case usd
    case eur
    case cny
    case aud

    /// Returns the API code string for the currency.
    var currencyOption: String {
        switch self {
        case .usd:
            return "USD"
        case .eur:
            return "EUR"
        case .cny:
            return "CNY"
        case .aud:
            return "AUD"
        }
    }
}
