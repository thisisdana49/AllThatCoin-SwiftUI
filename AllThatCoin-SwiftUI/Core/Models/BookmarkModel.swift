import Foundation

struct BookmarkModel: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let image: String
    let currentPrice: Double
    let priceChangePercentage24h: Double?
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case image
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case timestamp
    }
} 