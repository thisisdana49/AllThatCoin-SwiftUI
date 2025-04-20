import Foundation
import Combine

class CoinService: CoinServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        this.apiClient = apiClient
    }
    
    func fetchCoins() -> AnyPublisher<[CoinModel], Error> {
        return apiClient.fetch<[CoinModel]>("/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false")
    }
    
    func fetchCoinDetail(id: String) -> AnyPublisher<CoinModel, Error> {
        return apiClient.fetch<CoinModel>("/coins/markets?vs_currency=usd&ids=\(id)&order=market_cap_desc&per_page=1&page=1&sparkline=false")
            .map { coins in
                guard let coin = coins.first else {
                    throw APIError.networkError(NSError(domain: "", code: -1))
                }
                return coin
            }
            .eraseToAnyPublisher()
    }
    
    func searchCoins(query: String) -> AnyPublisher<[CoinModel], Error> {
        return apiClient.fetch<[CoinModel]>("/search?query=\(query)")
    }
} 