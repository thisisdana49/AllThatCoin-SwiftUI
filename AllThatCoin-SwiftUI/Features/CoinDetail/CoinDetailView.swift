import SwiftUI

// MARK: - Header View
struct CoinDetailHeaderView: View {
    let coin: MarketCoinModel
    let isBookmarked: Bool
    let onBookmarkTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: URL(string: coin.image)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 32, height: 32)
                
                Text(coin.name)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button {
                    onBookmarkTap()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .blue : .gray)
                }
            }
            
            Text(coin.currentPrice.formatted(.currency(code: "KRW")))
                .font(.title)
                .bold()
            
            HStack(spacing: 4) {
                Text("Today")
                    .foregroundColor(.secondary)
                Text((coin.priceChangePercentage24h ?? 0).formatted(.percent.precision(.fractionLength(2))))
                    .foregroundColor((coin.priceChangePercentage24h ?? 0) >= 0 ? .red : .blue)
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }
}

// MARK: - Price Stats View
struct PriceStatsView: View {
    let coin: MarketCoinModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                PriceStatBox(
                    title: "고가",
                    value: coin.high24h?.formatted(.currency(code: "KRW")) ?? "N/A",
                    titleColor: .red
                )
                
                PriceStatBox(
                    title: "저가",
                    value: coin.low24h?.formatted(.currency(code: "KRW")) ?? "N/A",
                    titleColor: .blue
                )
            }
            
            HStack(spacing: 20) {
                PriceStatBox(
                    title: "신고점",
                    value: coin.marketCap?.formatted(.currency(code: "KRW")) ?? "N/A",
                    titleColor: .red
                )
                
                PriceStatBox(
                    title: "신저점",
                    value: coin.totalVolume?.formatted(.currency(code: "KRW")) ?? "N/A",
                    titleColor: .blue
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Chart View
struct ChartView: View {
    let sparklineData: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SparklineChart(data: sparklineData)
                .frame(height: 200)
            
            Text("2/21 11:53:50 업데이트")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
    }
}

// MARK: - Main View
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
                    VStack(spacing: 24) {
                        CoinDetailHeaderView(
                            coin: coin,
                            isBookmarked: viewModel.state.isBookmarked,
                            onBookmarkTap: { viewModel.dispatch(.toggleBookmark) }
                        )
                        
                        PriceStatsView(coin: coin)
                        
                        if let sparklineData = coin.sparklineIn7D?.price {
                            ChartView(sparklineData: sparklineData)
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

struct PriceStatBox: View {
    let title: String
    let value: String
    let titleColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(titleColor)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SparklineChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let points = data.enumerated().map { (index, value) in
                CGPoint(
                    x: CGFloat(index) * (geometry.size.width / CGFloat(data.count - 1)),
                    y: (CGFloat(value) - CGFloat(data.min() ?? 0)) / CGFloat((data.max() ?? 1) - (data.min() ?? 0)) * geometry.size.height
                )
            }
            
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.3),
                        Color.purple.opacity(0.1),
                        Color.purple.opacity(0.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addLine(to: points[0])
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.closeSubpath()
                    }
                )
                
                // Line
                Path { path in
                    path.move(to: points[0])
                    for index in 1..<points.count {
                        let control1 = CGPoint(
                            x: points[index - 1].x + (points[index].x - points[index - 1].x) / 3,
                            y: points[index - 1].y
                        )
                        let control2 = CGPoint(
                            x: points[index - 1].x + 2 * (points[index].x - points[index - 1].x) / 3,
                            y: points[index].y
                        )
                        path.addCurve(to: points[index], control1: control1, control2: control2)
                    }
                }
                .stroke(Color.purple, lineWidth: 2)
            }
        }
    }
}

#Preview {
    NavigationView {
        CoinDetailView(coinId: "bitcoin")
    }
} 
