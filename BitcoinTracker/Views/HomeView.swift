//
//  HomeView.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = APIViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let price = viewModel.currentRate {
                Text("Bitcoin Price: \(price) \(viewModel.selectedCurrency.currencyOption)")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
            }

            Picker("Currency", selection: $viewModel.selectedCurrency) {
                ForEach(ExchangeCurrency.allCases, id: \.self) { currency in
                    Text(currency.currencyOption).tag(currency)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedCurrency) { _ in
                viewModel.fetchCurrentBitcoinPrice()
            }
            .padding()
        }
        .onAppear {
            viewModel.startFetchingPrice()
        }
        .onDisappear {
            viewModel.stopFetchingPrice()
        }
    }
}

#Preview {
    HomeView()
}
