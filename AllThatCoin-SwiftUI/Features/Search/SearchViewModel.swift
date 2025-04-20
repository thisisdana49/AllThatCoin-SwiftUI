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
    private var searchCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(coinService: CoinServiceProtocol = CoinService()) {
        self.state = SearchState()
        self.coinService = coinService
        loadBookmarkedCoins()
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
        // 자동 검색 제거
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
        // TODO: Implement bookmark persistence
        state.bookmarkedCoins = []
    }
    
    private func toggleBookmark(_ coinId: String) {
        if state.bookmarkedCoins.contains(coinId) {
            state.bookmarkedCoins.remove(coinId)
        } else {
            state.bookmarkedCoins.insert(coinId)
        }
        // TODO: Implement bookmark persistence
    }
} 
