import Foundation
import Combine

protocol CoinServiceProtocol {
    func fetchCoins() -> AnyPublisher<[MarketCoinModel], Error>
    func fetchCoinDetail(id: String) -> AnyPublisher<MarketCoinModel, Error>
    func searchCoins(query: String) -> AnyPublisher<SearchResult, Error>
} 