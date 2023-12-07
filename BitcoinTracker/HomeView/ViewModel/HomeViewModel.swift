//
//  HomeViewModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

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
    
    var timer: Timer?
    
    /// fetches the current Bitcoin exchange rate and starts a timer to trigger function every 10 seconds
    ///  Usecase: .onAppear{ }
    func startFetchingPrice() {
        withAnimation {
            fetchCurrentBitcoinPrice()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.fetchCurrentBitcoinPrice()
        }
    }
    
    ///  invalidates the timer to trigger the function repeatedly
    ///  Usecase: .onDissappear{ }
    func stopFetchingPrice() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Currency Change
    
    /// Changes the selected currency and fetches the latest rate.
    /// - Parameter newCurrency: The new currency to be set.
    func changeCurrency(to newCurrency: ExchangeCurrency) {
        selectedCurrency = newCurrency
        fetchCurrentBitcoinPrice()
    }
    
    // MARK: - Fetching Historical Data
    
    @Published var isHistoricalDataLoading: Bool = false
        
    func fetchHistoricalData() async {
        isHistoricalDataLoading = true
        do {
            let data = try await bitcoinTrackerModel.fetchHistoricalBitcoinData(currency: selectedCurrency)
            bitcoinTrackerModel.coreDataService.replaceHistoricalRates(rates: data)
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
