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
    case loadTrending
    case updateBookmarks
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
        
        // 북마크 서비스의 변경사항을 구독
        NotificationCenter.default.publisher(for: .bookmarkDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dispatch(.updateBookmarks)
            }
            .store(in: &cancellables)
        
        loadBookmarks()
    }
    
    func dispatch(_ action: MarketAction) {
        switch action {
        case .loadCoins:
            loadCoins()
        case .refreshCoins:
            refreshCoins()
        case .loadTrending:
            loadTrending()
        case .updateBookmarks:
            loadBookmarks()
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
    
    private func loadBookmarks() {
        state.bookmarkedCoins = bookmarkService.getBookmarkedCoins()
    }
    
    private func loadTrending() {
        print("🔄 Starting to load trending data...")
        state.isLoading = true
        state.error = nil
        
        coinService.fetchTrending()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.state.isLoading = false
                if case .failure(let error) = completion {
                    print("❌ Error loading trending data: \(error)")
                    self?.state.error = error
                }
            } receiveValue: { [weak self] response in
                print("✅ Received trending data - Coins: \(response.coins.count), NFTs: \(response.nfts.count)")
                self?.state.trendingCoins = response.coins
                self?.state.trendingNFTs = response.nfts
            }
            .store(in: &cancellables)
    }
} 
