import SwiftUI

struct CoinCardView: View {
    let name: String
    let symbol: String
    let price: Double
    let changePercentage: Double
    let isBookmarked: Bool
    let onBookmarkTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(symbol)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", price))
                    .font(.headline)
                
                Text(String(format: "%.2f%%", changePercentage))
                    .font(.subheadline)
                    .foregroundColor(changePercentage >= 0 ? .green : .red)
            }
            
            Button(action: onBookmarkTap) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(isBookmarked ? .blue : .gray)
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    CoinCardView(
        name: "Bitcoin",
        symbol: "BTC",
        price: 50000.0,
        changePercentage: 2.5,
        isBookmarked: true,
        onBookmarkTap: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
} 