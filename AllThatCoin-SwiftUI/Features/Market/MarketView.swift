import SwiftUI

struct MarketView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Market View")
            }
            .navigationTitle("Market")
        }
    }
}

#Preview {
    MarketView()
} 