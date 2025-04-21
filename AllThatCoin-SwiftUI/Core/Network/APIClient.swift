import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        }
    }
}

// 캐시 항목을 위한 구조체
struct CacheItem<T> {
    let data: T
    let timestamp: Date
    let expirationInterval: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    // 요청 간격 조절을 위한 변수들
    private let minimumRequestInterval: TimeInterval = 1.0 // 최소 1초 간격
    private var lastRequestTime: Date = Date.distantPast
    private let requestQueue = DispatchQueue(label: "com.allthatcoin.apiclient.requestQueue")
    
    // 캐싱을 위한 변수들
    private var cache: [String: CacheItem<Data>] = [:]
    private let defaultCacheExpiration: TimeInterval = 60 // 기본 1분 캐시
    
    private init() {}
    
    func fetch<T: Decodable>(_ endpoint: String, useCache: Bool = true, cacheExpiration: TimeInterval? = nil) -> AnyPublisher<T, Error> {
        print("🌐 API Request: \(baseURL + endpoint)")
        
        guard let url = URL(string: baseURL + endpoint) else {
            print("❌ Invalid URL: \(baseURL + endpoint)")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // 캐시 확인
        if useCache, let cachedData = getCachedData(for: endpoint, expiration: cacheExpiration) {
            print("📦 Using cached data for: \(endpoint)")
            return decodeData(cachedData, type: T.self)
        }
        
        // 요청 간격 조절
        return Future<T, Error> { promise in
            self.requestQueue.async {
                let now = Date()
                let timeSinceLastRequest = now.timeIntervalSince(self.lastRequestTime)
                
                if timeSinceLastRequest < self.minimumRequestInterval {
                    let delay = self.minimumRequestInterval - timeSinceLastRequest
                    print("⏱️ Waiting \(delay) seconds before making the next request")
                    Thread.sleep(forTimeInterval: delay)
                }
                
                self.lastRequestTime = Date()
                
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("❌ Network Error: \(error)")
                        promise(.failure(APIError.networkError(error)))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ Invalid HTTP Response")
                        promise(.failure(APIError.networkError(NSError(domain: "", code: -1))))
                        return
                    }
                    
                    print("📥 Response Status Code: \(httpResponse.statusCode)")
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        guard let data = data else {
                            promise(.failure(APIError.networkError(NSError(domain: "", code: -1))))
                            return
                        }
                        
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("📦 Response Data: \(jsonString)")
                        }
                        
                        // 응답 데이터를 캐시에 저장
                        if useCache {
                            self.cacheData(data, for: endpoint, expiration: cacheExpiration)
                        }
                        
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: data)
                            promise(.success(decodedData))
                        } catch {
                            print("❌ Decoding Error: \(error)")
                            promise(.failure(APIError.decodingError(error)))
                        }
                    case 429:
                        print("❌ Rate limit exceeded")
                        promise(.failure(APIError.rateLimitExceeded))
                    default:
                        print("❌ Server Error: \(httpResponse.statusCode)")
                        promise(.failure(APIError.serverError(httpResponse.statusCode)))
                    }
                }
                
                task.resume()
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 캐시에서 데이터 가져오기
    private func getCachedData(for endpoint: String, expiration: TimeInterval?) -> Data? {
        guard let cacheItem = cache[endpoint] else {
            return nil
        }
        
        let expirationInterval = expiration ?? defaultCacheExpiration
        let isExpired = Date().timeIntervalSince(cacheItem.timestamp) > expirationInterval
        
        if isExpired {
            print("🗑️ Cache expired for: \(endpoint)")
            cache.removeValue(forKey: endpoint)
            return nil
        }
        
        return cacheItem.data
    }
    
    // 데이터를 캐시에 저장
    private func cacheData(_ data: Data, for endpoint: String, expiration: TimeInterval?) {
        let expirationInterval = expiration ?? defaultCacheExpiration
        let cacheItem = CacheItem(data: data, timestamp: Date(), expirationInterval: expirationInterval)
        cache[endpoint] = cacheItem
        print("💾 Cached data for: \(endpoint)")
    }
    
    // 데이터 디코딩
    private func decodeData<T: Decodable>(_ data: Data, type: T.Type) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                promise(.success(decodedData))
            } catch {
                print("❌ Decoding Error: \(error)")
                promise(.failure(APIError.decodingError(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 캐시 초기화
    func clearCache() {
        cache.removeAll()
        print("🧹 Cache cleared")
    }
} 