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
        state.isLoading = true
        state.error = nil
        
        coinService.fetchCoinDetail(id: coinId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.state.isLoading = false
                if case .failure(let error) = completion {
                    self?.state.error = error
                }
            } receiveValue: { [weak self] coin in
                self?.state.coin = coin
            }
            .store(in: &cancellables)
    }
    
    private func toggleBookmark() {
        bookmarkService.toggleBookmark(for: coinId)
        state.isBookmarked = bookmarkService.isBookmarked(coinId: coinId)
    }
    
    private func loadBookmarkStatus() {
        state.isBookmarked = bookmarkService.isBookmarked(coinId: coinId)
    }
} 