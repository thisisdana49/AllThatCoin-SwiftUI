import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                Text("Search Results")
            }
            .searchable(text: $searchText, prompt: "Search coins")
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
} 