import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        MyFavoriteSection(bookmarkedCoins: viewModel.state.bookmarkedCoins, coins: viewModel.state.coins)
                        TopCoinsSection(coins: viewModel.state.coins)
                        TopNFTsSection(nfts: viewModel.state.trendingNFTs)
                    }
                    .padding(.vertical, 24)
                }
                
                if viewModel.state.isLoading {
                    LoadingView(message: "Loading market data...")
                }
            }
            .navigationTitle("Crypto Coin")
            .onAppear {
                viewModel.dispatch(.loadCoins)
                viewModel.dispatch(.loadTrending)
            }
        }
    }
}

// MARK: - Section Views
struct MyFavoriteSection: View {
    let bookmarkedCoins: Set<String>
    let coins: [MarketCoinModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Favorite")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(bookmarkedCoins.sorted(), id: \.self) { coinId in
                        if let coin = coins.first(where: { $0.id == coinId }) {
                            NavigationLink(destination: CoinDetailView(coinId: coin.id)) {
                                FavoriteCoinCard(coin: coin)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

struct TopCoinsSection: View {
    let coins: [MarketCoinModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top15 Coin")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<5) { groupIndex in
                        VStack(spacing: 12) {
                            ForEach(0..<3) { itemIndex in
                                let index = groupIndex * 3 + itemIndex
                                if index < min(coins.count, 15) {
                                    RankedCoinLink(rank: index + 1, coin: coins[index])
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

struct RankedCoinLink: View {
    let rank: Int
    let coin: MarketCoinModel
    
    var body: some View {
        NavigationLink(destination: CoinDetailView(coinId: coin.id)) {
            RankedItemCell(
                rank: rank,
                imageUrl: coin.image,
                name: coin.name,
                symbol: coin.symbol.uppercased(),
                price: coin.currentPrice.formatted(.currency(code: "USD")),
                priceChangePercentage: coin.priceChangePercentage24h ?? 0
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TopNFTsSection: View {
    let nfts: [TrendingNFT]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top7 NFT")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<3) { groupIndex in
                        VStack(spacing: 12) {
                            ForEach(0..<3) { itemIndex in
                                let index = groupIndex * 3 + itemIndex
                                if index < min(nfts.count, 7) {
                                    RankedItemCell(
                                        rank: index + 1,
                                        imageUrl: nfts[index].thumb,
                                        name: nfts[index].name,
                                        symbol: nfts[index].symbol,
                                        price: "1.70 ETH",
                                        priceChangePercentage: 0
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Cell Views
struct RankedItemCell: View {
    let rank: Int
    let imageUrl: String
    let name: String
    let symbol: String
    let price: String
    let priceChangePercentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            // Image
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
            // Name and Symbol
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price and Change
            VStack(alignment: .trailing, spacing: 2) {
                Text(price)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(priceChangePercentage.formatted(.percent.precision(.fractionLength(2))))
                    .font(.caption)
                    .foregroundColor(priceChangePercentage >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

struct FavoriteCoinCard: View {
    let coin: MarketCoinModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: coin.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                
                Text(coin.symbol.uppercased())
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.currentPrice.formatted(.currency(code: "USD")))
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text((coin.priceChangePercentage24h ?? 0).formatted(.percent.precision(.fractionLength(2))))
                    .font(.subheadline)
                    .foregroundColor((coin.priceChangePercentage24h ?? 0) >= 0 ? .green : .red)
            }
        }
        .padding()
        .frame(width: 140)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    MarketView()
}
