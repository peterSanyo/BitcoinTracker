//
//  HomeViewModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import Combine
import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    private var bitcoinTrackerModel: BitcoinTrackerModel
    private var moc: NSManagedObjectContext?

    init(context: NSManagedObjectContext) {
        let apiService = APIService()
        let coreDataService = CoreDataService(context: context)
        self.bitcoinTrackerModel = BitcoinTrackerModel(apiService: apiService, coreDataService: coreDataService)
    }

    func setManagedObjectContext(_ context: NSManagedObjectContext) {
        moc = context
    }
    
    @Published var errorMessage: String? = nil
    
    @Published var currentRate: Double?
    @Published var selectedCurrency: ExchangeCurrency = .eur
    
    /// Fetches the current Bitcoin price and updates the `currentRate`.
    /// Utilizes the `BitcoinTrackerModel` to retrieve the latest rate from the API.
    func fetchCurrentBitcoinPrice() {
        getCachedBitcoinRate()

        bitcoinTrackerModel.fetchCurrentBitcoinPrice(currency: selectedCurrency) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rate):
                    // since it is repeatedly triggered: only overwrite UserDefaults when values changed
                    if self?.currentRate != rate {
                        self?.currentRate = rate
                        UserDefaults.standard.setLastBitcoinRate(rate)
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    if self?.currentRate == nil {
                        self?.currentRate = nil
                    }
                }
            }
        }
    }
    
    // MARK: - UserDefaults
    
    func getCachedBitcoinRate() {
        if let cachedRate = UserDefaults.standard.getLastBitcoinRate() {
            currentRate = cachedRate
        }
    }

    // MARK: -  Continous updates of current exchange rate
    
    private var priceUpdateSubscription: AnyCancellable?

    /// Starts a timer to continuously fetch the current Bitcoin exchange rate.
    /// Intended for use when the view appears.
    func startFetchingPrice() {
        priceUpdateSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                print("Tick")
                self?.fetchCurrentBitcoinPrice()
            }
    }

    /// Invalidates the timer that updates the exchange rate.
    /// Intended for use when the view disappears.
    func stopFetchingPrice() {
        priceUpdateSubscription?.cancel()
        print("Timer cancelled")
        priceUpdateSubscription = nil
    }
    
    // MARK: - Currency Change
    
    /// Changes the selected currency and fetches the latest Bitcoin rate.
    /// - Parameter newCurrency: The new currency to fetch the rate for.
    func changeCurrency(to newCurrency: ExchangeCurrency) {
        selectedCurrency = newCurrency
        fetchCurrentBitcoinPrice()
    }
    
    // MARK: - Fetching Historical Data
    
    @Published var isHistoricalDataLoading: Bool = false

    /// Asynchronously fetches historical Bitcoin data and updates Core Data.
    /// Shows loading state while fetching and updates the `isHistoricalDataLoading` property.
    func fetchHistoricalData() async {
        DispatchQueue.main.async {
            self.isHistoricalDataLoading = true
        }
        
        do {
            let data = try await bitcoinTrackerModel.fetchHistoricalBitcoinData(currency: selectedCurrency)
            DispatchQueue.main.async {
                self.bitcoinTrackerModel.replaceHistoricalRates(rates: data)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        DispatchQueue.main.async {
            self.isHistoricalDataLoading = false
        }
    }
}
