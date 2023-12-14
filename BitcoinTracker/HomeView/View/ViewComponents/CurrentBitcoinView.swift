//
//  CurrentBitcoinRateInterface.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 07.12.23.
//
import SwiftUI

struct CurrentBitcoinView: View {
    @Binding var selectedCurrency: ExchangeCurrency
    @Binding var currentRate: Double?
    @Binding var errorMessage: String?

    @State private var previousRate: Double? = nil

    var body: some View {
        VStack {
            rateDisplay
            currencyPicker
        }
        .foregroundColor(.white)
        .padding()
        .onAppear {
            previousRate = currentRate
        }
        .onChange(of: currentRate) { newValue in
            previousRate = newValue
        }
    }

    private var rateDisplay: some View {
        Group {
            if let price = currentRate {
                RateView(price: price, previousRate: previousRate)
            } else if let message = errorMessage {
                Text("Error: \(message)")
            } else {
                Text("No data available.")
            }
        }
    }

    private var currencyPicker: some View {
        Picker("Currency", selection: $selectedCurrency) {
            ForEach(ExchangeCurrency.allCases, id: \.self) { currency in
                Text(currency.currencyOption).tag(currency)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct CurrentBitcoinRateInterface_Previews: PreviewProvider {
    @State static var selectedCurrency = ExchangeCurrency.usd
    @State static var currentRate: Double? = 42000.32
    @State static var errorMessage: String? = nil

    static var previews: some View {
        ZStack {
            Color.black.opacity(0.9)

            VStack {
                CurrentBitcoinView(
                    selectedCurrency: $selectedCurrency,
                    currentRate: $currentRate,
                    errorMessage: $errorMessage
                )
            }
        }
    }
}
