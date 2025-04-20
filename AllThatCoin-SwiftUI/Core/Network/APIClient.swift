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
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.networkError(NSError(domain: "", code: -1))
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.serverError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
} 