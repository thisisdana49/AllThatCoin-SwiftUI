import Foundation
import Combine

struct BookmarkState {
    var bookmarkedCoins: [MarketCoinModel] = []
    var isLoading = false
    var error: Error?
}

enum BookmarkAction {
    case loadBookmarkedCoins
    case toggleBookmark(String)
}

class BookmarkViewModel: ObservableObject {
    @Published private(set) var state: BookmarkState
    private let coinService: CoinServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(coinService: CoinServiceProtocol = CoinService(),
         bookmarkService: BookmarkServiceProtocol = BookmarkService.shared) {
        self.state = BookmarkState()
        self.coinService = coinService
        self.bookmarkService = bookmarkService
        setupBookmarkObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func dispatch(_ action: BookmarkAction) {
        switch action {
        case .loadBookmarkedCoins:
            loadBookmarkedCoins()
        case .toggleBookmark(let coinId):
            toggleBookmark(coinId)
        }
    }
    
    private func loadBookmarkedCoins() {
        let bookmarkedIds = bookmarkService.getBookmarkedCoins()
        guard !bookmarkedIds.isEmpty else {
            state.bookmarkedCoins = []
            return
        }
        
        state.isLoading = true
        state.error = nil
        
        // 북마크된 모든 코인의 상세 정보를 가져옵니다
        let publishers = bookmarkedIds.map { coinId in
            coinService.fetchCoinDetail(id: coinId)
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.state.isLoading = false
                if case .failure(let error) = completion {
                    self?.state.error = error
                }
            } receiveValue: { [weak self] coins in
                self?.state.bookmarkedCoins = coins
            }
            .store(in: &cancellables)
    }
    
    private func toggleBookmark(_ coinId: String) {
        bookmarkService.toggleBookmark(for: coinId)
    }
    
    private func setupBookmarkObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookmarkChanged),
            name: .bookmarkChanged,
            object: nil
        )
    }
    
    @objc private func handleBookmarkChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let coinId = userInfo["coinId"] as? String,
              let isBookmarked = userInfo["isBookmarked"] as? Bool else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if isBookmarked {
                // 북마크가 추가된 경우, 코인 상세 정보를 가져와서 목록에 추가
                self?.loadCoinDetail(coinId: coinId)
            } else {
                // 북마크가 제거된 경우, 목록에서 해당 코인을 제거
                self?.state.bookmarkedCoins.removeAll { $0.id == coinId }
            }
        }
    }
    
    private func loadCoinDetail(coinId: String) {
        coinService.fetchCoinDetail(id: coinId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state.error = error
                }
            } receiveValue: { [weak self] coin in
                self?.state.bookmarkedCoins.append(coin)
            }
            .store(in: &cancellables)
    }
} 
