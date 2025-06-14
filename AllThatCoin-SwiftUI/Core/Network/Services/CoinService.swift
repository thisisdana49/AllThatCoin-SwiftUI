import Foundation
import Combine

class CoinService: CoinServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchCoins() -> AnyPublisher<[MarketCoinModel], Error> {
        let endpoint = "/coins/markets?vs_currency=krw&order=market_cap_desc&per_page=100&page=1&sparkline=true"
        print("Fetching coins with endpoint: \(endpoint)")
        return apiClient.fetch(endpoint, useCache: true, cacheExpiration: 60) // 1분 캐시
    }
    
    func fetchCoinDetail(id: String) -> AnyPublisher<MarketCoinModel, Error> {
        let endpoint = "/coins/markets?vs_currency=krw&ids=\(id)&order=market_cap_desc&per_page=1&page=1&sparkline=true"
        print("Fetching coin detail with endpoint: \(endpoint)")
        return apiClient.fetch(endpoint, useCache: true, cacheExpiration: 300) // 5분 캐시
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
        return apiClient.fetch(endpoint, useCache: true, cacheExpiration: 300) // 5분 캐시
    }
    
    func fetchTrending() -> AnyPublisher<TrendingResponse, Error> {
        let endpoint = "/search/trending"
        print("Fetching trending coins and NFTs with endpoint: \(endpoint)")
        return apiClient.fetch(endpoint, useCache: true, cacheExpiration: 300) // 5분 캐시
    }
    
    // 캐시 초기화
    func clearCache() {
        apiClient.clearCache()
    }
}
