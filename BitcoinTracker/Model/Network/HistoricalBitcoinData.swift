//
//  HistoricalBitcoinData.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import Foundation

/// `HistoricalDataResponse` decodes the JSON response from the CryptoCompare API.
/// It follows a nested structure to match the incoming JSON format, ensuring conformance to Codable protocol.
struct HistoricalDataResponse: Codable {
    /// `DataContainer` serves as an intermediate layer to match the nested JSON structure.
    /// It contains the array of `HistoricalOHLCV` data, representing individual OHLCV entries.
    let data: DataContainer

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }

    /// `DataContainer` holds the actual data points in the form of an array of `HistoricalOHLCV` structures.
    /// This separation is to ensure the correct mapping between the JSON response and the Swift structures.
    struct DataContainer: Codable {
        /// Array of historical OHLCV data points, each representing a time interval's trading information.
        let data: [HistoricalRate]

        enum CodingKeys: String, CodingKey {
            case data = "Data"
        }
    }
}

/// `HistoricalOHLCV` represents a single data point in the historical Bitcoin data.
/// Each property corresponds to a key element in the trading data (open, high, low, close, volume) for a specific time interval.
struct HistoricalRate: Codable {
    let time: Int /// Unix timestamp indicating the start of the time interval for this data point.
    let high: Double /// Highest trading price of Bitcoin in the interval.
    let low: Double /// Lowest trading price of Bitcoin in the interval.
    let open: Double /// Opening trading price of Bitcoin at the start of the interval.
    let close: Double /// Closing trading price of Bitcoin at the end of the interval.
    let volumefrom: Double /// Total volume of Bitcoin traded from the opening to the closing of the interval.
    let volumeto: Double /// Total volume of the target currency traded in the same interval.

    enum CodingKeys: String, CodingKey {
        case time, high, low, open, close, volumefrom, volumeto
    }
}

// MARK: - Testing: Sample Data 

extension HistoricalRate {
    static var example: HistoricalRate {
        return HistoricalRate(
            time: 1700611200,
            high: 34777.38,
            low: 32683.59,
            open: 32784.53,
            close: 34373.1,
            volumefrom: 2931.88,
            volumeto: 99173701.24
        )
    }
}


extension HistoricalDataResponse {
    static var example: HistoricalDataResponse? {
        let jsonString = """
        {
            "Response": "Success",
            "Message": "",
            "HasWarning": false,
            "Type": 100,
            "RateLimit": {},
            "Data": {
                "Aggregated": false,
                "TimeFrom": 1700611200,
                "TimeTo": 1701734400,
                "Data": [
                    {
                        "time": 1700611200,
                        "high": 34777.38,
                        "low": 32683.59,
                        "open": 32784.53,
                        "volumefrom": 2931.88,
                        "volumeto": 99173701.24,
                        "close": 34373.1,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1700697600,
                        "high": 34480.83,
                        "low": 33839.84,
                        "open": 34373.1,
                        "volumefrom": 1526.25,
                        "volumeto": 52223681.74,
                        "close": 34220.67,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1700784000,
                        "high": 35143.68,
                        "low": 34191.25,
                        "open": 34220.67,
                        "volumefrom": 2448.96,
                        "volumeto": 84800695.79,
                        "close": 34489.16,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1700870400,
                        "high": 34619.02,
                        "low": 34394.61,
                        "open": 34489.16,
                        "volumefrom": 694.42,
                        "volumeto": 23974225.43,
                        "close": 34558.04,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1700956800,
                        "high": 34586.23,
                        "low": 33991.44,
                        "open": 34558.04,
                        "volumefrom": 1011.97,
                        "volumeto": 34711843.42,
                        "close": 34259.12,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701043200,
                        "high": 34374.46,
                        "low": 33607.28,
                        "open": 34259.12,
                        "volumefrom": 2078.99,
                        "volumeto": 70425220.23,
                        "close": 34002.93,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701129600,
                        "high": 34945.54,
                        "low": 33580.91,
                        "open": 34002.93,
                        "volumefrom": 2534.84,
                        "volumeto": 86923726.22,
                        "close": 34387.37,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701216000,
                        "high": 35001.9,
                        "low": 34278.62,
                        "open": 34387.37,
                        "volumefrom": 1932.04,
                        "volumeto": 66851996,
                        "close": 34520.93,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701302400,
                        "high": 34766.51,
                        "low": 34383.08,
                        "open": 34520.93,
                        "volumefrom": 1827.16,
                        "volumeto": 63202463.93,
                        "close": 34646.81,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701388800,
                        "high": 35868.47,
                        "low": 34542.16,
                        "open": 34646.81,
                        "volumefrom": 2885.78,
                        "volumeto": 102156181.96,
                        "close": 35569.92,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701475200,
                        "high": 36553.98,
                        "low": 35532.71,
                        "open": 35569.92,
                        "volumefrom": 1489.64,
                        "volumeto": 53614452.52,
                        "close": 36260.43,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701561600,
                        "high": 36901.98,
                        "low": 36072.14,
                        "open": 36260.43,
                        "volumefrom": 1292.25,
                        "volumeto": 47111909.06,
                        "close": 36726.64,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701648000,
                        "high": 39123.59,
                        "low": 36725.84,
                        "open": 36726.64,
                        "volumefrom": 5012.68,
                        "volumeto": 191685153.94,
                        "close": 38749.36,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    },
                    {
                        "time": 1701734400,
                        "high": 41182.89,
                        "low": 38284.94,
                        "open": 38749.36,
                        "volumefrom": 4356.69,
                        "volumeto": 172604885.43,
                        "close": 40837.95,
                        "conversionType": "direct",
                        "conversionSymbol": ""
                    }
                ]
            }
        }
        """

        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(HistoricalDataResponse.self, from: jsonData)
    }
}

