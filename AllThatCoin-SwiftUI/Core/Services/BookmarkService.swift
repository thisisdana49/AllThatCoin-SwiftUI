import Foundation
import Combine

protocol BookmarkServiceProtocol {
    func getBookmarkedCoins() -> Set<String>
    func toggleBookmark(for coinId: String)
    func isBookmarked(coinId: String) -> Bool
}

class BookmarkService: BookmarkServiceProtocol {
    static let shared = BookmarkService()
    private let defaults = UserDefaults.standard
    private let bookmarkKey = "bookmarked_coins"
    
    private init() {}
    
    func getBookmarkedCoins() -> Set<String> {
        let array = defaults.array(forKey: bookmarkKey) as? [String] ?? []
        return Set(array)
    }
    
    func toggleBookmark(for coinId: String) {
        var bookmarks = getBookmarkedCoins()
        if bookmarks.contains(coinId) {
            bookmarks.remove(coinId)
        } else {
            bookmarks.insert(coinId)
        }
        defaults.set(Array(bookmarks), forKey: bookmarkKey)
    }
    
    func isBookmarked(coinId: String) -> Bool {
        return getBookmarkedCoins().contains(coinId)
    }
} 