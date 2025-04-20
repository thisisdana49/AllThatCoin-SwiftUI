import Foundation
import Combine

protocol CoinServiceProtocol {
    func fetchCoins() -> AnyPublisher<[CoinModel], Error>
    func fetchCoinDetail(id: String) -> AnyPublisher<CoinModel, Error>
    func searchCoins(query: String) -> AnyPublisher<[CoinModel], Error>
} 