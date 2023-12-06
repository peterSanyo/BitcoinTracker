//
//  HomeView.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()

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

            if viewModel.isHistoricalDataLoading {
                ProgressView()
            } else if !viewModel.historicalData.isEmpty {
                List(viewModel.historicalData, id: \.time) { data in
                    HStack {
                        Text("Date: \(convertTimestampToDate(TimeInterval(data.time)))")
                        Spacer()
                        Text("Open: \(data.open), Close: \(data.close)")
                    }
                }
            } else {
                Text("No historical data available.")
            }
        }
        .onAppear {
            viewModel.startFetchingPrice()
        }
        .onDisappear {
            viewModel.stopFetchingPrice()
        }
    }

    private func convertTimestampToDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    HomeView()
}
