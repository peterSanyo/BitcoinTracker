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
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack {
               
                CurrentBitcoinView(selectedCurrency: $viewModel.selectedCurrency, currentRate: $viewModel.currentRate, errorMessage: $viewModel.errorMessage)
                
                HStack {
                    lastUpdatedTimeStamp
                    Spacer()
                    fetchButton
                }
                ScrollView {
                    ForEach(historicalRates, id: \.self) { rate in
                        BitcoinRateView(rate: rate)
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
        .ignoresSafeArea(edges: .bottom)
    }
    
    var lastUpdatedTimeStamp: some View {
        VStack(alignment: .leading) {
            Text("Last Updated:")
                .font(.caption)
            Group {
                if let mostRecentUpdate = historicalRates.first?.formattedUpdate {
                    Text(mostRecentUpdate)
                } else {
                    Text("Last Updated: Not available")
                }
            }
            .bold()
        }
        .foregroundColor(.white)
    }
    
    var fetchButton: some View {
        Group {
            Button {
                Task {
                    await viewModel.fetchHistoricalData()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(lineWidth: 2)
                    Text("Reload Data")
                }
                .foregroundColor(.white)
                .frame(maxHeight: 44)
            }
        }
        .padding(.leading, 50)
    }
    
    func BitcoinRateView(rate: StoredHistoricalRate) -> some View {
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
    
    func TendencyView(changePercentage: Double) -> some View {
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


