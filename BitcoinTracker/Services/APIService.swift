//
//  APIService.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 07.12.23.
//

import Foundation

/// Service class responsible for fetching cryptocurrency data from an external API.
class APIService {
    
    /// Fetches the current Bitcoin price for a specified currency.
    /// Makes a network request to the CryptoCompare API and retrieves the latest Bitcoin price in the given currency.
    ///
    /// Documentation: https://min-api.cryptocompare.com/documentation?key=Price&cat=SingleSymbolPriceEndpoint
    /// API Endpoint: https://min-api.cryptocompare.com/data/v2/histoday?fsym=BTC&tsym=EUR&limit=14&toTs=1701863383
    /// Example Response: {"CNY":163338.95}
    ///
    /// - Parameters:
    ///   - currency: The currency for which to fetch the Bitcoin price (e.g., USD, EUR).
    ///   - completion: A completion handler that returns the fetched price as a `Double` or an error.
    func fetchCurrentBitcoinPrice(currency: ExchangeCurrency, completion: @escaping (Result<Double, Error>) -> Void) {
        let urlString = APIConstants.baseUrlString + currency.currencyOption
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)

        if let apiKey = ProcessInfo.processInfo.environment[APIConstants.apiKey] {
            request.addValue("Apikey \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            do {
                if let data = data {
                    let decodedResponse = try JSONDecoder().decode([String: Double].self, from: data)
                    if let rate = decodedResponse[currency.currencyOption] {
                        completion(.success(rate))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Currency not found"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    /// Fetches historical Bitcoin data
    /// Asynchronously retrieves daily open, high, low, close, volumefrom, and volumeto data for Bitcoin over the past 14 days.
    ///
    /// API Documentation: https://min-api.cryptocompare.com/documentation?key=FuturesIndices&cat=index_v1_historical_days
    /// API Endpoint: https://min-api.cryptocompare.com/data/v2/histoday?fsym=BTC&tsym=USD&limit=13&toTs=<current_timestamp>`.
    /// - `fsym`: parameter of the cryptocurrency symbol of interest
    /// - `tsym`: the currency symbol to convert into.
    /// - `limit`: amount of days tracked backwards. The API starts counting from 0, so setting this to 13 retrieves 14 days of data.
    /// - `toTs`: Unix timestamp to fetch historical data up to the end of the previous day.
    ///
    /// Note: The `time` property in the response is a Unix timestamp, representing
    /// the number of seconds that have elapsed since January 1, 1970 (midnight UTC/GMT).
    /// Example response:
    /// ```
    /// {
    ///     "Response": "Success",
    ///     "Data": {
    ///         "Data": [
    ///             {
    ///                 "time": 1700611200,
    ///                 "high": 37866.63,
    ///                 "low": 35656.41,
    ///                 "open": 35758.72,
    ///                 "close": 37424.2,
    ///                 "volumefrom": 36262.61,
    ///                 "volumeto": 1335151412.8
    ///             },
    ///             // More data...
    ///         ]
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter currency: The currency symbol (e.g., USD, EUR) to convert Bitcoin data into referring to `ExchangeCurrency`.
    /// - Returns: An array of `HistoricalRate` data representing daily Bitcoin values.
    /// - Throws: An error if the network request fails or data parsing fails.
    func fetchHistoricalBitcoinData(currency: ExchangeCurrency) async throws -> [HistoricalRate] {
        // Calculate Unix timestamp for 23:59 GMT of yesterday
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let endOfYesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: yesterday)!)
        let toTs = Int(endOfYesterday.timeIntervalSince1970) - 1

        let amountOfDaysReturned = 13

        let urlString = "https://min-api.cryptocompare.com/data/v2/histoday?fsym=BTC&tsym=\(currency.currencyOption)&limit=\(amountOfDaysReturned)&toTs=\(toTs)&api_key=\(APIKey)"
        print("urlString: \(urlString) ")

        guard let url = URL(string: urlString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        if let rawJSONString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(rawJSONString)")
        }

        let decodedResponse = try JSONDecoder().decode(HistoricalDataResponse.self, from: data)

        return decodedResponse.data.data
    }
}

// MARK: - Constants:

enum APIConstants {
    static let baseUrlString = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms="
    static let apiKey = APIKey
}
