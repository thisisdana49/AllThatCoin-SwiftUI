import Foundation

struct MarketCoinModel: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    let totalVolume: Double?
    let high24h: Double?
    let low24h: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
    }
} 