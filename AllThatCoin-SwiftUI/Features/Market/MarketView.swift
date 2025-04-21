import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Trending Coins Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trending Coins")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(viewModel.state.trendingCoins) { coin in
                                        TrendingCoinCard(coin: coin.item)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Trending NFTs Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trending NFTs")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(viewModel.state.trendingNFTs) { nft in
                                        TrendingNFTCard(nft: nft)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                if viewModel.state.isLoading {
                    LoadingView(message: "Loading market data...")
                }
            }
            .navigationTitle("Market")
            .onAppear {
                viewModel.dispatch(.loadTrending)
            }
        }
    }
}

struct TrendingCoinCard: View {
    let coin: TrendingCoinItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: coin.thumb)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.symbol.uppercased())
                    .font(.headline)
                Text(coin.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("#\(coin.marketCapRank)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TrendingNFTCard: View {
    let nft: TrendingNFT
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: nft.thumb)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nft.name)
                    .font(.headline)
                Text(nft.symbol)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    MarketView()
}
