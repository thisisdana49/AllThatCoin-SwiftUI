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
                        .padding(.horizontal)
                        
                        // Price Info
                        VStack(spacing: 4) {
                            Text(coin.currentPrice.formatted(.currency(code: "USD")))
                                .font(.title)
                                .bold()
                            
                            HStack(spacing: 4) {
                                Image(systemName: (coin.priceChangePercentage24h ?? 0) >= 0 ? "arrow.up.right" : "arrow.down.right")
                                Text((coin.priceChangePercentage24h ?? 0).formatted(.percent.precision(.fractionLength(2))))
                            }
                            .foregroundColor((coin.priceChangePercentage24h ?? 0) >= 0 ? .green : .red)
                        }
                        
                        // Chart
                        if let sparklineData = coin.sparklineIn7D?.price {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("7 Day Chart")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                SparklineChart(data: sparklineData)
                                    .frame(height: 200)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Price Stats
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Price Statistics")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                PriceStatRow(title: "고가", value: coin.high24h?.formatted(.currency(code: "USD")) ?? "N/A")
                                PriceStatRow(title: "저가", value: coin.low24h?.formatted(.currency(code: "USD")) ?? "N/A")
                                PriceStatRow(title: "신고점", value: coin.marketCap?.formatted(.currency(code: "USD")) ?? "N/A")
                                PriceStatRow(title: "신저점", value: coin.totalVolume?.formatted(.currency(code: "USD")) ?? "N/A")
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.dispatch(.loadCoinDetail)
        }
    }
}

struct PriceStatRow: View {
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

struct SparklineChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let points = data.enumerated().map { (index, value) in
                    CGPoint(
                        x: CGFloat(index) * (geometry.size.width / CGFloat(data.count - 1)),
                        y: (CGFloat(value) - CGFloat(data.min() ?? 0)) / CGFloat((data.max() ?? 1) - (data.min() ?? 0)) * geometry.size.height
                    )
                }
                
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.purple, lineWidth: 2)
        }
    }
}

#Preview {
    NavigationView {
        CoinDetailView(coinId: "bitcoin")
    }
} 
