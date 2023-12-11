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

struct RateView: View {
    let price: Double
    let previousRate: Double?

    var body: some View {
        let components = formatPrice(price)
        let previousComponents = formatPrice(previousRate)

        return HStack(alignment: .bottom, spacing: 2) {
            PriceComponentsView(components: components, previousComponents: previousComponents)
        }
    }

    private func formatPrice(_ price: Double?) -> [[Character]] {
        guard let price = price else { return [[" "], [" "]] }
        return String(format: "%.2f", price).split(separator: ".").map { Array($0) }
    }
}

struct PriceComponentsView: View {
    var components: [[Character]]
    var previousComponents: [[Character]]

    var body: some View {
        ForEach(0..<components.count, id: \.self) { index in
            let component = components[index]
            let previousComponent = previousComponents.indices.contains(index) ? previousComponents[index] : []

            ForEach(0..<component.count, id: \.self) { charIndex in
                let char = component[charIndex]
                let previousChar = charIndex < previousComponent.count ? previousComponent[charIndex] : " "

                if let digit = Int(String(char)) {
                    FlippingNumberView(
                        digit: digit,
                        previousDigit: Int(String(previousChar)) ?? -1
                    )
                } else if char == "." {
                    decimalPoints
                }
            }
        }
    }

    var decimalPoints: some View {
        Text(".")
            .font(.system(size: 30, weight: .bold))
    }
}

struct FlippingNumberView: View {
    let digit: Int
    let previousDigit: Int

    private var shouldFlip: Bool {
        return digit != previousDigit
    }

    private var numberOfFlips: Double {
        shouldFlip ? Double(1) * 360 : 0
    }

    private var animationDuration: Double {
        Double.random(in: 0.5 ... 1.2)
    }

    var body: some View {
        Group {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(lineWidth: 2)
                .frame(width: 40, height: 60)
                .overlay(
                    Text("\(digit)")
                        .font(.system(size: 30, weight: .bold))
                )
        }
        .rotation3DEffect(
            .degrees(numberOfFlips),
            axis: (x: 1.0, y: 0.0, z: 0.0),
            anchor: .center,
            perspective: 0
        )
        .animation(shouldFlip ? .easeInOut(duration: animationDuration) : .default, value: digit)
        .foregroundColor(.white)
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
