import SwiftUI

struct CoinDetailView: View {
    @StateObject private var viewModel: CoinDetailViewModel
    
    init(coinId: String) {
        _viewModel = StateObject(wrappedValue: CoinDetailViewModel(coinId: coinId))
    }
    
    var body: some View {
        ZStack {
            if viewModel.state.isLoading {
                LoadingView(message: "Loading coin details...")
            } else if let error = viewModel.state.error {
                ErrorView(message: error.localizedDescription) {
                    viewModel.dispatch(.loadCoinDetail)
                }
            } else if let coin = viewModel.state.coin {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            AsyncImage(url: URL(string: coin.image)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading) {
                                Text(coin.name)
                                    .font(.title2)
                                    .bold()
                                Text(coin.symbol.uppercased())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                viewModel.dispatch(.toggleBookmark)
                            } label: {
                                Image(systemName: viewModel.state.isBookmarked ? "bookmark.fill" : "bookmark")
                                    .foregroundColor(viewModel.state.isBookmarked ? .blue : .gray)
                            }
                        }
                        .padding()
                        
                        // Price Section
                        VStack(spacing: 8) {
                            Text(String(format: "$%.2f", coin.currentPrice))
                                .font(.title)
                                .bold()
                            
                            HStack {
                                Image(systemName: coin.priceChangePercentage24h ?? 0 >= 0 ? "arrow.up.right" : "arrow.down.right")
                                Text(String(format: "%.2f%%", abs(coin.priceChangePercentage24h ?? 0)))
                            }
                            .foregroundColor(coin.priceChangePercentage24h ?? 0 >= 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        
                        // Market Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Market Stats")
                                .font(.headline)
                            
                            StatRow(title: "Market Cap", value: String(format: "$%.2f", coin.marketCap ?? 0))
                            StatRow(title: "Market Cap Rank", value: "#\(coin.marketCapRank ?? 0)")
                            StatRow(title: "24h Volume", value: String(format: "$%.2f", coin.totalVolume ?? 0))
                            StatRow(title: "24h High", value: String(format: "$%.2f", coin.high24h ?? 0))
                            StatRow(title: "24h Low", value: String(format: "$%.2f", coin.low24h ?? 0))
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.dispatch(.loadCoinDetail)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

#Preview {
    NavigationView {
        CoinDetailView(coinId: "bitcoin")
    }
} 