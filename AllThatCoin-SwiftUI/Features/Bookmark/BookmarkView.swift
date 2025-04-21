import SwiftUI

struct BookmarkView: View {
    @StateObject private var viewModel = BookmarkViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.state.isLoading {
                    ProgressView()
                } else if viewModel.state.bookmarkedCoins.isEmpty {
                    emptyStateView
                } else {
                    bookmarkListView
                }
            }
            .navigationTitle("북마크")
            .onAppear {
                viewModel.dispatch(.loadBookmarkedCoins)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("북마크된 코인이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("마켓 탭에서 관심 있는 코인을 북마크해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var bookmarkListView: some View {
        List(viewModel.state.bookmarkedCoins) { coin in
            NavigationLink(destination: CoinDetailView(coinId: coin.id)) {
                CoinCardView(
                    name: coin.name,
                    symbol: coin.symbol.uppercased(),
                    price: coin.currentPrice,
                    changePercentage: coin.priceChangePercentage24h ?? 0,
                    isBookmarked: true
                ) {
                    viewModel.dispatch(.toggleBookmark(coin.id))
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.dispatch(.loadBookmarkedCoins)
        }
    }
}

#Preview {
    BookmarkView()
} 
