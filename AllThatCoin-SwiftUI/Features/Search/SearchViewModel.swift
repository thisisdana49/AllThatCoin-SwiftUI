import Foundation
import Combine

struct SearchState {
    var searchText = ""
    var searchResults: [SearchCoinModel] = []
    var isLoading = false
    var error: Error?
    var bookmarkedCoins: Set<String> = []
}

enum SearchAction {
    case updateSearchText(String)
    case search(String)
    case clearSearch
    case toggleBookmark(String)
}

class SearchViewModel: ObservableObject {
    @Published private(set) var state: SearchState
    private let coinService: CoinServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private var searchCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(coinService: CoinServiceProtocol = CoinService(),
         bookmarkService: BookmarkServiceProtocol = BookmarkService.shared) {
        self.state = SearchState()
        self.coinService = coinService
        self.bookmarkService = bookmarkService
        loadBookmarkedCoins()
        setupBookmarkObserver()
    }
    
    func dispatch(_ action: SearchAction) {
        switch action {
        case .updateSearchText(let text):
            updateSearchText(text)
        case .search(let query):
            search(query: query)
        case .clearSearch:
            clearSearch()
        case .toggleBookmark(let coinId):
            toggleBookmark(coinId)
        }
    }
    
    private func updateSearchText(_ text: String) {
        state.searchText = text
    }
    
    private func search(query: String) {
        guard !query.isEmpty else {
            clearSearch()
            return
        }
        
        print("Searching for coins with query: \(query)")
        state.isLoading = true
        state.error = nil
        
        // 이전 검색을 취소
        searchCancellable?.cancel()
        
        // 새로운 검색 시작
        searchCancellable = coinService.searchCoins(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.state.isLoading = false
                if case .failure(let error) = completion {
                    print("Search error: \(error)")
                    self?.state.error = error
                }
            } receiveValue: { [weak self] result in
                print("Received \(result.coins.count) search results")
                self?.state.searchResults = result.coins
            }
    }
    
    private func clearSearch() {
        state.searchText = ""
        state.searchResults = []
        state.error = nil
        searchCancellable?.cancel()
    }
    
    private func loadBookmarkedCoins() {
        state.bookmarkedCoins = bookmarkService.getBookmarkedCoins()
    }
    
    private func toggleBookmark(_ coinId: String) {
        bookmarkService.toggleBookmark(for: coinId)
        loadBookmarkedCoins()
    }
    
    private func setupBookmarkObserver() {
        NotificationCenter.default.publisher(for: .bookmarkDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadBookmarkedCoins()
            }
            .store(in: &cancellables)
    }
} 
