//
//  APIService.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import Foundation

/// Service class responsible for fetching cryptocurrency data from the CryptoCompare API.
class CryptoCompareService {
    enum APIConstants {
        static let baseUrlString = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms="
        static let apiKey = "CRYPTOCOMPARE_API_KEY"
    }

    /// Fetches the current Bitcoin price for a given currency.
    /// Documentation: https://min-api.cryptocompare.com/documentation?key=Price&cat=SingleSymbolPriceEndpoint
    /// - Example Respond:  {"CNY":163338.95}
    ///
    /// - Parameters:
    ///   - currency: The currency for which to fetch the Bitcoin price.
    ///   - completion: A completion handler with the result containing the price or an error.
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
}
