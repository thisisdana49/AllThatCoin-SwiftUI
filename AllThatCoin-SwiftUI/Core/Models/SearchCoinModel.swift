import Foundation

struct SearchResult: Codable {
    let coins: [SearchCoinModel]
}

struct SearchCoinModel: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    let thumb: String
    let large: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case marketCapRank = "market_cap_rank"
        case thumb
        case large
    }
} 