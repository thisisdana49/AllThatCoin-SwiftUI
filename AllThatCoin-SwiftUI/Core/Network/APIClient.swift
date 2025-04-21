import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
}

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    private init() {}
    
    func fetch<T: Decodable>(_ endpoint: String) -> AnyPublisher<T, Error> {
        print("🌐 API Request: \(baseURL + endpoint)")
        
        guard let url = URL(string: baseURL + endpoint) else {
            print("❌ Invalid URL: \(baseURL + endpoint)")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid HTTP Response")
                    throw APIError.networkError(NSError(domain: "", code: -1))
                }
                
                print("📥 Response Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Server Error: \(httpResponse.statusCode)")
                    throw APIError.serverError(httpResponse.statusCode)
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Response Data: \(jsonString)")
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                print("❌ Decoding Error: \(error)")
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
} 