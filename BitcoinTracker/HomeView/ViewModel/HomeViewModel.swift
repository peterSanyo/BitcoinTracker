//
//  HomeViewModel.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    private var bitcoinTrackerModel = BitcoinTrackerModel()
    
    private var moc: NSManagedObjectContext?
    init() {}
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
        guard let moc = moc else {
            print("Managed Object Context not set.")
            return
        }

        isHistoricalDataLoading = true
        
        let now = Date()
        updateLastUpdateTimestamp(now, in: moc)

        do {
            let data = try await bitcoinTrackerModel.fetchHistoricalBitcoinData(currency: selectedCurrency)
            
            if moc.hasChanges {
                // Delete old data from Core Data before saving new data
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StoredHistoricalRate.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try moc.execute(deleteRequest)
                } catch {
                    print("Error in deleting old records: \(error)")
                }
                
                let now = Date()
                for rateData in data {
                    let newRate = StoredHistoricalRate(context: moc)
                    newRate.lastUpdate = now
                    newRate.time = Int32(rateData.time)
                    newRate.high = rateData.high
                    newRate.low = rateData.low
                    newRate.open = rateData.open
                    newRate.close = rateData.close
                    newRate.volumefrom = rateData.volumefrom
                    newRate.volumeto = rateData.volumeto
                }
                try moc.save()
                
                // Important: Save the context after making changes
                if moc.hasChanges {
                    try moc.save()
                }
                
                DispatchQueue.main.async {
                    self.isHistoricalDataLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isHistoricalDataLoading = false
            }
        }
    }
    
    private func updateLastUpdateTimestamp(_ date: Date, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<StoredHistoricalRate> = StoredHistoricalRate.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { $0.lastUpdate = date }
            try context.save()
        } catch {
            print("Failed to update lastUpdate timestamp: \(error)")
        }
    }
}
