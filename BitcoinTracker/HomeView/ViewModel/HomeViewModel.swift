//
//  HomeViewModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    private var bitcoinTrackerModel = BitcoinTrackerModel()
    
    @Published var errorMessage: String? = nil
    @Published var currentRate: Double?
    @Published var selectedCurrency: ExchangeCurrency = .eur
    
    func fetchCurrentBitcoinPrice() {
        getCachedBitcoinRate()

        bitcoinTrackerModel.fetchCurrentBitcoinPrice(currency: selectedCurrency) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rate):
                    self?.currentRate = rate
                    UserDefaults.standard.setLastBitcoinRate(rate)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    if self?.currentRate == nil {
                        self?.currentRate = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Caching
    
    func getCachedBitcoinRate() {
        if let cachedRate = UserDefaults.standard.getLastBitcoinRate() {
            currentRate = cachedRate
        }
    }
    
    func getCachedHistoricalData() {
        if let cachedData = UserDefaults.standard.getLastHistoricalData() {
            historicalData = cachedData
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
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
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
    
    @Published var historicalData: [HistoricalOHLCV] = []
    @Published var isHistoricalDataLoading: Bool = false
        
    func fetchHistoricalData() async {
        isHistoricalDataLoading = true
        getCachedHistoricalData()
        do {
            let data = try await bitcoinTrackerModel.fetchHistoricalBitcoinData(currency: selectedCurrency)
            DispatchQueue.main.async {
                self.historicalData = data
                self.isHistoricalDataLoading = false
                UserDefaults.standard.setLastHistoricalData(data)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isHistoricalDataLoading = false
            }
        }
        
    }
}
