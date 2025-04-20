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
}

class CoinDetailViewModel: ObservableObject {
    @Published private(set) var state: CoinDetailState
    private let coinId: String
    private let coinService: CoinServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(coinId: String, coinService: CoinServiceProtocol = CoinService()) {
        self.coinId = coinId
        self.coinService = coinService
        self.state = CoinDetailState()
    }
    
    func dispatch(_ action: CoinDetailAction) {
        switch action {
        case .loadCoinDetail:
            loadCoinDetail()
        case .toggleBookmark:
            toggleBookmark()
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
        state.isBookmarked.toggle()
        // TODO: Implement bookmark persistence
    }
} 