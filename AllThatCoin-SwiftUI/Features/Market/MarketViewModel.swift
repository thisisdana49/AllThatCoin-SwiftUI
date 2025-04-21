import Foundation
import Combine

struct MarketState {
    var coins: [MarketCoinModel] = []
    var trendingCoins: [TrendingCoin] = []
    var trendingNFTs: [TrendingNFT] = []
    var isLoading = false
    var error: Error?
    var bookmarkedCoins: Set<String> = []
}

enum MarketAction {
    case loadCoins
    case refreshCoins
    case toggleBookmark(String)
    case loadBookmarks
    case loadTrending
}

class MarketViewModel: ObservableObject {
    @Published private(set) var state: MarketState
    private let coinService: CoinServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(coinService: CoinServiceProtocol = CoinService(),
         bookmarkService: BookmarkServiceProtocol = BookmarkService.shared) {
        self.state = MarketState()
        self.coinService = coinService
        self.bookmarkService = bookmarkService
        loadBookmarks()
    }
    
    func dispatch(_ action: MarketAction) {
        switch action {
        case .loadCoins:
            loadCoins()
        case .refreshCoins:
            refreshCoins()
        case .toggleBookmark(let coinId):
            toggleBookmark(coinId)
        case .loadBookmarks:
            loadBookmarks()
        case .loadTrending:
            loadTrending()
        }
    }
    
    private func loadCoins() {
        state.isLoading = true
        state.error = nil
        
        coinService.fetchCoins()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.state.isLoading = false
                if case .failure(let error) = completion {
                    self?.state.error = error
                }
            } receiveValue: { [weak self] coins in
                self?.state.coins = coins
            }
            .store(in: &cancellables)
    }
    
    private func refreshCoins() {
        state.coins = []
        loadCoins()
    }
    
    private func toggleBookmark(_ coinId: String) {
        bookmarkService.toggleBookmark(for: coinId)
        state.bookmarkedCoins = bookmarkService.getBookmarkedCoins()
    }
    
    private func loadBookmarks() {
        state.bookmarkedCoins = bookmarkService.getBookmarkedCoins()
    }
    
    private func loadTrending() {
        state.isLoading = true
        state.error = nil
        
        coinService.fetchTrending()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.state.isLoading = false
                if case .failure(let error) = completion {
                    self?.state.error = error
                }
            } receiveValue: { [weak self] response in
                self?.state.trendingCoins = response.coins
                self?.state.trendingNFTs = response.nfts
            }
            .store(in: &cancellables)
    }
} 
