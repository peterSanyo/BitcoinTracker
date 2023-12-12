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

    var body: some View {
        ZStack {
            backgroundView
            content
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.setManagedObjectContext(moc)
            viewModel.fetchCurrentBitcoinPrice()
            viewModel.updateTimestampAndRefreshData()
            viewModel.startFetchingPrice()
        }
        .onChange(of: viewModel.selectedCurrency) { _ in
            Task { await viewModel.fetchHistoricalData() }
        }
        .onDisappear {
            viewModel.stopFetchingPrice()
        }
    }

    private var backgroundView: some View {
        Color.black.opacity(0.9).ignoresSafeArea()
    }

    private var content: some View {
        VStack {
            CurrentBitcoinView(
                selectedCurrency: $viewModel.selectedCurrency,
                currentRate: $viewModel.currentRate,
                errorMessage: $viewModel.errorMessage
            )
            historicHeader
            historicDataList
        }
        .padding()
    }

    private var historicHeader: some View {
        HStack {
            lastUpdatedTimeStamp
            Spacer()
            fetchButton
        }
    }

    private var historicDataList: some View {
        ScrollView {
            ForEach(viewModel.historicalRates, id: \.self) { rate in
                BitcoinRateView(rate: rate)
            }
        }
    }

    private var lastUpdatedTimeStamp: some View {
        VStack(alignment: .leading) {
            Text("Last Update:")
                .font(.caption)
            Text(viewModel.formattedLastUpdated)
                .bold()
        }
        .foregroundColor(.white)
    }

    private var fetchButton: some View {
        Group {
            Button {
                viewModel.updateTimestampAndRefreshData()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(lineWidth: 2)
                    Text("Load Data")
                }
                .foregroundColor(.white)
            }
        }
        .frame(maxWidth: 120, maxHeight: 44)
        .padding(.leading, 50)
    }

    private func BitcoinRateView(rate: StoredHistoricalRate) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.white, lineWidth: 2)

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Close: \(rate.close.formatted(.number.precision(.fractionLength(2))))")
                        .bold()
                    Text("Date: \(rate.dateOfTimestamp)")
                        .font(.caption)
                }
                Spacer()
                TendencyView(changePercentage: rate.dailyChangePercentage)
            }
            .padding()
        }
        .foregroundColor(.white)
        .padding(2)
    }

    private func TendencyView(changePercentage: Double) -> some View {
        HStack {
            Text("\(changePercentage >= 0 ? "+" : "")\(changePercentage.formatted(.number.precision(.fractionLength(1))))%")

            Image(systemName: "arrow.forward.circle")
                .rotationEffect(.degrees(changePercentage < 0 ? 45 : -45))
                .animation(.easeInOut(duration: 1.0), value: changePercentage)
        }
        .foregroundColor(changePercentage < 0 ? .red : .green)
        .bold()
    }
}
