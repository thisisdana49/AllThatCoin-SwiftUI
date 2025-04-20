//
//  ContentView.swift
//  AllThatCoin-SwiftUI
//
//  Created by 조다은 on 4/20/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MarketView()
                .tabItem {
                    Label("Market", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            BookmarkView()
                .tabItem {
                    Label("Bookmark", systemImage: "bookmark")
                }
        }
    }
}

#Preview {
    ContentView()
}
