import Foundation

struct MarketCoinModel: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Int
    let marketCapRank: Int
    let priceChangePercentage24h: Double
    let lastUpdated: String
    let totalVolume: Double?
    let high24h: Double?
    let low24h: Double?

    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case lastUpdated = "last_updated"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"

    }
}

struct TrendingResponse: Codable {
    let coins: [TrendingCoin]
    let nfts: [TrendingNFT]
}

struct TrendingCoin: Codable, Identifiable {
    var id: String { item.id }
    let item: TrendingCoinItem
}

struct TrendingCoinItem: Codable {
    let id: String
    let coinId: Int
    let name: String
    let symbol: String
    let marketCapRank: Int
    let thumb: String
    let small: String
    let large: String
    let slug: String
    let priceBtc: Double
    let score: Int
    let data: TrendingCoinData
    
    enum CodingKeys: String, CodingKey {
        case id
        case coinId = "coin_id"
        case name
        case symbol
        case marketCapRank = "market_cap_rank"
        case thumb
        case small
        case large
        case slug
        case priceBtc = "price_btc"
        case score
        case data
    }
}

struct TrendingCoinData: Codable {
    let price: Double
    let priceBtc: String
    let priceChangePercentage24h: PriceChangePercentage
    let marketCap: String
    let marketCapBtc: String
    let totalVolume: String
    let totalVolumeBtc: String
    let sparkline: String
    let content: CoinContent
    
    enum CodingKeys: String, CodingKey {
        case price
        case priceBtc = "price_btc"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCap = "market_cap"
        case marketCapBtc = "market_cap_btc"
        case totalVolume = "total_volume"
        case totalVolumeBtc = "total_volume_btc"
        case sparkline
        case content
    }
}

struct PriceChangePercentage: Codable {
    let usd: Double
    let btc: Double
    let eth: Double
    let krw: Double
}

struct CoinContent: Codable {
    let title: String
    let description: String
}

// NFT 관련 모델
struct TrendingNFT: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let thumb: String
    let nftContractId: Int
    let nativeCurrencySymbol: String
    let floorPriceInNativeCurrency: Double
    let floorPrice24hPercentageChange: Double
    let data: NFTData
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case thumb
        case nftContractId = "nft_contract_id"
        case nativeCurrencySymbol = "native_currency_symbol"
        case floorPriceInNativeCurrency = "floor_price_in_native_currency"
        case floorPrice24hPercentageChange = "floor_price_24h_percentage_change"
        case data
    }
}

struct NFTData: Codable {
    let floorPrice: String
    let floorPriceInUsd24hPercentageChange: String
    let h24Volume: String
    let h24AverageSalePrice: String
    let sparkline: String
    let content: NFTContent
    
    enum CodingKeys: String, CodingKey {
        case floorPrice = "floor_price"
        case floorPriceInUsd24hPercentageChange = "floor_price_in_usd_24h_percentage_change"
        case h24Volume = "h24_volume"
        case h24AverageSalePrice = "h24_average_sale_price"
        case sparkline
        case content
    }
}

struct NFTContent: Codable {
    let title: String
    let description: String
} 
