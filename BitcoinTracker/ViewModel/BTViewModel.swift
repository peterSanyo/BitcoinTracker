//
//  BTViewModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import SwiftUI

/// ViewModel for handling the logic of cryptocurrency data retrieval.
class APIViewModel: ObservableObject {
    private var apiService = CryptoCompareService()
       
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentRate: Double?
    @Published var selectedCurrency: ExchangeCurrency = .eur
    
    /// Fetches the current Bitcoin price for the selected currency.
    func fetchCurrentBitcoinPrice() {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchCurrentBitcoinPrice(currency: selectedCurrency) { [weak self] result in
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
    
    func startFetchingPrice() {
        withAnimation {
            // Call immediately and then start the timer
            fetchCurrentBitcoinPrice()
            
            timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
                self?.fetchCurrentBitcoinPrice()
            }
        }
    }

    func stopFetchingPrice() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Changes the selected currency and fetches the latest rate.
    /// - Parameter newCurrency: The new currency to be set.
    func changeCurrency(to newCurrency: ExchangeCurrency) {
        selectedCurrency = newCurrency
        fetchCurrentBitcoinPrice()
    }
}
