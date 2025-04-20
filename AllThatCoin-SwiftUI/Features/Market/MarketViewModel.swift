import Foundation
import Combine

enum MarketAction {
    case loadCoins
    case refreshCoins
    case toggleBookmark(String)
}

struct MarketState {
    var coins: [CoinModel] = []
    var isLoading = false
    var error: Error?
    var bookmarkedCoins: Set<String> = []
}

class MarketViewModel: ObservableObject {
    @Published private(set) var state = MarketState()
    private let coinService: CoinServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(coinService: CoinServiceProtocol = CoinService()) {
        self.coinService = coinService
        loadBookmarkedCoins()
    }
    
    func dispatch(_ action: MarketAction) {
        switch action {
        case .loadCoins:
            loadCoins()
        case .refreshCoins:
            refreshCoins()
        case .toggleBookmark(let coinId):
            toggleBookmark(coinId)
        }
    }
    
    private func loadCoins() {
        guard !state.isLoading else { return }
        
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
