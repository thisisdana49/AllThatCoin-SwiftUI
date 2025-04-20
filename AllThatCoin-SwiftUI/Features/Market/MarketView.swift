import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.state.isLoading && viewModel.state.coins.isEmpty {
                    LoadingView(message: "Loading coins...")
                } else if let error = viewModel.state.error {
                    ErrorView(message: error.localizedDescription) {
                        viewModel.dispatch(.refreshCoins)
                    }
                } else {
                    coinList
                }
            }
            .navigationTitle("Market")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.dispatch(.refreshCoins)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            viewModel.dispatch(.loadCoins)
        }
    }
    
    private var coinList: some View {
        List(viewModel.state.coins) { coin in
            NavigationLink(destination: CoinDetailView(coinId: coin.id)) {
                CoinCardView(
                    name: coin.name,
                    symbol: coin.symbol.uppercased(),
                    price: coin.currentPrice,
                    changePercentage: coin.priceChangePercentage24h ?? 0,
                    isBookmarked: viewModel.state.bookmarkedCoins.contains(coin.id)
                ) {
                    viewModel.dispatch(.toggleBookmark(coin.id))
                }
            }
        }
        .refreshable {
            viewModel.dispatch(.refreshCoins)
        }
    }
}

#Preview {
    MarketView()
} 