import Foundation
import Combine

class CoinService: CoinServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchCoins() -> AnyPublisher<[MarketCoinModel], Error> {
        let endpoint = "/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true"
        print("Fetching coins with endpoint: \(endpoint)")
        return apiClient.fetch(endpoint)
    }
    
    func fetchCoinDetail(id: String) -> AnyPublisher<MarketCoinModel, Error> {
        let endpoint = "/coins/markets?vs_currency=usd&ids=\(id)&order=market_cap_desc&per_page=1&page=1&sparkline=true"
        print("Fetching coin detail with endpoint: \(endpoint)")
        return apiClient.fetch(endpoint)
            .tryMap { (coins: [MarketCoinModel]) -> MarketCoinModel in
                guard let coin = coins.first else {
                    throw APIError.networkError(NSError(domain: "", code: -1))
                }
                return coin
            }
            .eraseToAnyPublisher()
    }
    
    func searchCoins(query: String) -> AnyPublisher<SearchResult, Error> {
        let endpoint = "/search?query=\(query)"
        print("Searching coins with endpoint: \(endpoint)")
        return apiClient.fetch(endpoint)
    }
    
    func fetchTrending() -> AnyPublisher<TrendingResponse, Error> {
        let endpoint = "/search/trending"
        print("Fetching trending coins and NFTs with endpoint: \(endpoint)")
        return apiClient.fetch(endpoint)
    }
    
    // 캐시 초기화
    func clearCache() {
        apiClient.clearCache()
    }
}
