import Foundation
import Combine

struct CoinDetailState {
    var coin: MarketCoinModel?
    var isLoading = false
    var error: Error?
    var isBookmarked = false
}

enum CoinDetailAction {
    case loadCoinDetail
    case toggleBookmark
    case loadBookmarkStatus
}

class CoinDetailViewModel: ObservableObject {
    @Published private(set) var state: CoinDetailState
    private let coinId: String
    private let coinService: CoinServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(coinId: String, 
         coinService: CoinServiceProtocol = CoinService(),
         bookmarkService: BookmarkServiceProtocol = BookmarkService.shared) {
        self.coinId = coinId
        self.coinService = coinService
        self.bookmarkService = bookmarkService
        self.state = CoinDetailState()
        loadBookmarkStatus()
        setupBookmarkObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func dispatch(_ action: CoinDetailAction) {
        switch action {
        case .loadCoinDetail:
            loadCoinDetail()
        case .toggleBookmark:
            toggleBookmark()
        case .loadBookmarkStatus:
            loadBookmarkStatus()
        }
    }
    
    private func loadCoinDetail() {
        print("🔄 Loading coin detail for ID: \(coinId)")
        state.isLoading = true
        state.error = nil
        
        coinService.fetchCoinDetail(id: coinId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.state.isLoading = false
                if case .failure(let error) = completion {
                    print("❌ Error loading coin detail: \(error)")
                    self?.state.error = error
                }
            } receiveValue: { [weak self] coin in
                print("✅ Received coin detail: \(coin.name)")
                self?.state.coin = coin
            }
            .store(in: &cancellables)
    }
    
    private func toggleBookmark() {
        bookmarkService.toggleBookmark(for: coinId)
        loadBookmarkStatus() // 즉시 상태 업데이트
    }
    
    private func loadBookmarkStatus() {
        state.isBookmarked = bookmarkService.isBookmarked(coinId: coinId)
    }
    
    private func setupBookmarkObserver() {
        NotificationCenter.default.publisher(for: .bookmarkDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadBookmarkStatus()
            }
            .store(in: &cancellables)
    }
} 