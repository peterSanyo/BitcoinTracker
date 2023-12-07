//
//  HomeView.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @FetchRequest(
        entity: StoredHistoricalRate.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \StoredHistoricalRate.time, ascending: false)
        ]
    ) var historicalRates: FetchedResults<StoredHistoricalRate>

    var body: some View {
        VStack {
            if let price = viewModel.currentRate {
                Text("Bitcoin Price: \(price) \(viewModel.selectedCurrency.currencyOption)")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("No data available.")
            }

            Picker("Currency", selection: $viewModel.selectedCurrency) {
                ForEach(ExchangeCurrency.allCases, id: \.self) { currency in
                    Text(currency.currencyOption).tag(currency)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedCurrency) { newCurrency in
                viewModel.changeCurrency(to: newCurrency)
            }
            .padding()

            Button("Fetch Historical Data") {
                Task {
                    await viewModel.fetchHistoricalData()
                }
            }

            if let mostRecentUpdate = historicalRates.first?.formattedUpdate {
                Text("Last Updated: \(mostRecentUpdate)")
            } else {
                Text("Last Updated: Not available")
            }

            List(historicalRates, id: \.self) { rate in
                VStack(alignment: .leading) {
                    Text("Date: \(rate.dateOfTimestamp)")
                    Text("Close: \(rate.close)")
                    Text("Tendency: \(rate.dailyChangePercentage)%")
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.setManagedObjectContext(moc)
            viewModel.startFetchingPrice()
        }
        .onDisappear {
            viewModel.stopFetchingPrice()
        }
    }
}
