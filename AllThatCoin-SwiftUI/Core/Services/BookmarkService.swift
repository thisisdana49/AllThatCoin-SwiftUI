import Foundation
import Combine

protocol BookmarkServiceProtocol {
    func getBookmarkedCoins() -> Set<String>
    func toggleBookmark(for coinId: String)
    func isBookmarked(coinId: String) -> Bool
}

extension Notification.Name {
    static let bookmarkChanged = Notification.Name("bookmarkChanged")
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
        
        // 북마크 상태 변경 알림
        NotificationCenter.default.post(
            name: .bookmarkChanged,
            object: nil,
            userInfo: ["coinId": coinId, "isBookmarked": bookmarks.contains(coinId)]
        )
    }
    
    func isBookmarked(coinId: String) -> Bool {
        return getBookmarkedCoins().contains(coinId)
    }
} 