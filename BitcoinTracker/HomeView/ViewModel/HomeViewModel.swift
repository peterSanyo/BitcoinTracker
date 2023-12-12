//
//  HomeViewModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import Combine
import CoreData
import Network
import SwiftUI

class HomeViewModel: ObservableObject {
    private var bitcoinTrackerModel: BitcoinTrackerModel
    private var moc: NSManagedObjectContext?

    init(context: NSManagedObjectContext) {
        let apiService = APIService()
        let coreDataService = CoreDataService(context: context)
        self.bitcoinTrackerModel = BitcoinTrackerModel(apiService: apiService, coreDataService: coreDataService)
        printAllStoredHistoricRates()
    }

    /// Sets the managed object context for Core Data operations.
    func setManagedObjectContext(_ context: NSManagedObjectContext) {
        moc = context
    }

    @Published var errorMessage: String? = nil
    @Published var currentRate: Double?
    @Published var selectedCurrency: ExchangeCurrency = .eur

    // MARK: - Checking Network availability

    // MARK: -  Continous updates of current exchange rate in UserDefaults

    /// Fetches the current Bitcoin price and updates the `currentRate`.
    /// Uses the `BitcoinTrackerModel` to retrieve the latest rate from the API and caches it.
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

    //

    /// Retrieves the cached Bitcoin rate from user defaults.
    func getCachedBitcoinRate() {
        if let cachedRate = UserDefaults.standard.getLastBitcoinRate() {
            currentRate = cachedRate
        }
    }

    // MARK: -  Feature: Continous Updates

    private var priceUpdateSubscription: AnyCancellable?

    /// Starts a timer to continuously fetch the current Bitcoin exchange rate.
    /// Intended for use when the view appears.
    func startFetchingPrice() {
        priceUpdateSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in // weak self to prevent strong referenc cycle (ARC)
                print("Tick")
                self?.fetchCurrentBitcoinPrice()
            }
    }

    /// Stops the timer that updates the exchange rate.
    /// Intended for use when the view disappears.
    func stopFetchingPrice() {
        priceUpdateSubscription?.cancel()
        print("Timer cancelled")
        priceUpdateSubscription = nil
    }

    // MARK: - Timestamp Update

    @Published var lastUpdated: Date?

    /// Updates the last update timestamp and refreshes the historical rates.
    func updateTimestampAndRefreshData() {
        Task {
            await fetchHistoricalData()
            DispatchQueue.main.async {
                self.lastUpdated = Date()
            }
        }
    }

    var formattedLastUpdated: String {
        guard let lastUpdated = lastUpdated else { return "Not available" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd.MMM.yy, HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "CET") // Central European Time
        return formatter.string(from: lastUpdated)
    }

    // MARK: - Feature: Currency Change

    /// Changes the selected currency and triggers fetching of the latest Bitcoin rate and historical data.
    /// - Parameter newCurrency: The new currency to fetch the rate for.
    func changeCurrency(to newCurrency: ExchangeCurrency) {
        selectedCurrency = newCurrency
        fetchCurrentBitcoinPrice()
        Task {
            await fetchHistoricalData()
        }
        bitcoinTrackerModel.printAllStoredHistoricRates() // Debugging
    }

    // MARK: - Fetching Historical Data with CoreData

    @Published var historicalRates: [StoredHistoricalRate] = []
    @Published var isHistoricalDataLoading: Bool = false

    /// Asynchronously fetches historical Bitcoin data based on the current network availability.
    /// - When the network is available, it fetches the latest historical data for the selected currency
    ///   from the API, updates the Core Data storage with the new data, and then updates the `historicalRates`
    ///   published property with data fetched from Core Data.
    /// - If the network is unavailable, it directly loads the historical data from Core Data and updates
    ///   the `historicalRates` published property.
    /// - The method also manages the `isHistoricalDataLoading` published property to reflect the loading
    ///   state of the historical data, which can be used to show/hide loading indicators in the UI.
    /// - In case of a network fetch failure, it sets an error message in the `errorMessage` published property.
    func fetchHistoricalData() async {
        DispatchQueue.main.async {
            self.isHistoricalDataLoading = true
        }
        do {
            let rates = try await bitcoinTrackerModel.fetchHistoricalBitcoinData(currency: selectedCurrency)
            await replaceHistoricalRates(rates: rates)
            DispatchQueue.main.async {
                self.historicalRates = self.fetchStoredHistoricalRates()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isHistoricalDataLoading = false
            }
        }

        DispatchQueue.main.async {
            self.historicalRates = self.fetchStoredHistoricalRates()
            self.isHistoricalDataLoading = false
        }
    }

    /// Fetches stored historical rates from Core Data.
    func fetchStoredHistoricalRates() -> [StoredHistoricalRate] {
        guard let moc = moc else {
            return []
        }
        let fetchRequest: NSFetchRequest<StoredHistoricalRate> = StoredHistoricalRate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currency == %@", selectedCurrency.currencyOption)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \StoredHistoricalRate.time, ascending: false)]

        do {
            let fetchedRates = try moc.fetch(fetchRequest)
            return fetchedRates
        } catch {
            print("Error fetching stored historical rates: \(error)")
            return []
        }
    }

    /// Replaces the existing historical rates in Core Data with new ones.
    private func replaceHistoricalRates(rates: [HistoricalRate]) async {
        bitcoinTrackerModel.replaceHistoricalRates(rates: rates, for: selectedCurrency)
    }

    // MARK: - Debugging

    /// Prints all stored historical rates for debugging purposes.
    func printAllStoredHistoricRates() {
        bitcoinTrackerModel.printAllStoredHistoricRates()
    }
}
