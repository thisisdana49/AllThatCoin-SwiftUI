import Foundation
import Combine

extension Notification.Name {
    static let bookmarkDidChange = Notification.Name("bookmarkDidChange")
    static let bookmarkChanged = Notification.Name("bookmarkChanged")
}

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
        
        // 북마크 변경 알림 발송
        NotificationCenter.default.post(name: .bookmarkDidChange, object: nil)
    }
    
    func isBookmarked(coinId: String) -> Bool {
        return getBookmarkedCoins().contains(coinId)
    }
} 
