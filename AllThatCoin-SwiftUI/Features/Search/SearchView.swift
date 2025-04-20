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
                .onChange(of: searchText) { newValue in
                    viewModel.dispatch(.updateSearchText(newValue))
                }
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
            NavigationLink(destination: CoinDetailView(coinId: coin.id)) {
                CoinCardView(
                    name: coin.name,
                    symbol: coin.symbol.uppercased(),
                    price: 0.0,
                    changePercentage: 0.0,
                    isBookmarked: viewModel.state.bookmarkedCoins.contains(coin.id)
                ) {
                    viewModel.dispatch(.toggleBookmark(coin.id))
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    SearchView()
} 
