import SwiftUI

struct BookmarkView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Bookmarked Coins")
            }
            .navigationTitle("Bookmarks")
        }
    }
}

#Preview {
    BookmarkView()
} 