//
//  HomeViewModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    private var bitcoinTrackerModel = BitcoinTrackerModel()
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentRate: Double?
    @Published var selectedCurrency: ExchangeCurrency = .eur
    
    /// Fetches the current Bitcoin price for the selected currency.
    func fetchCurrentBitcoinPrice() {
        isLoading = true
        errorMessage = nil
        
        bitcoinTrackerModel.fetchCurrentBitcoinPrice(currency: selectedCurrency) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let rate):
                    self?.currentRate = rate
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: -  Continously updating the exchange rate
    
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
        do {
            let data = try await bitcoinTrackerModel.fetchHistoricalBitcoinData(currency: selectedCurrency)
            DispatchQueue.main.async {
                self.historicalData = data
                self.isHistoricalDataLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isHistoricalDataLoading = false
            }
        }
    }
}
