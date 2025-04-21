import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                        .padding()
                    
                    // Results
                    if viewModel.state.isLoading {
                        LoadingView(message: "Searching...")
                    } else if let error = viewModel.state.error {
                        ErrorView(message: error.localizedDescription) {
                            viewModel.dispatch(.search(viewModel.state.searchText))
                        }
                    } else if viewModel.state.searchResults.isEmpty && !viewModel.state.searchText.isEmpty {
                        emptyResultsView
                    } else {
                        searchResultsList
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search coins...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onSubmit {
                    viewModel.dispatch(.search(searchText))
                }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    viewModel.dispatch(.clearSearch)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No results found")
                .font(.headline)
            
            Text("Try searching for a different coin")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchResultsList: some View {
        List(viewModel.state.searchResults) { coin in
            HStack {
                NavigationLink(destination: CoinDetailView(coinId: coin.id)) {
                    CoinSearchResultRow(
                        name: coin.name,
                        symbol: coin.symbol.uppercased()
                    )
                }
                
                Spacer()
                
                // 북마크 버튼
                Button {
                    viewModel.dispatch(.toggleBookmark(coin.id))
                } label: {
                    Image(systemName: viewModel.state.bookmarkedCoins.contains(coin.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(viewModel.state.bookmarkedCoins.contains(coin.id) ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(.plain)
    }
}

struct CoinSearchResultRow: View {
    let name: String
    let symbol: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
            Text(symbol)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
} 
