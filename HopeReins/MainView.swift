//
//  MainView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/16/23.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("selection") private var selectedTab: String?
    var body: some View {
        NavigationSplitView(sidebar: {
            Sidebar(selectedTab: $selectedTab)
                .frame(minWidth: 250)
        }, detail: {
            DetailView(selectedTab: $selectedTab)
        })
    }
}

#Preview {
    ContentView()
}

struct DetailView: View {
    @Binding var selectedTab: String?
    var body: some View {
        switch selectedTab {
        case "Profile":
             ProfileView()
        case "Home":
            HomeView()
        case "New Entry":
            EntryView()
        case "All Patients":
            PatientsView()
        case "Scheduler":
            Text("Scheduler")
        case "Media":
            Text("Media")
        case .none:
            Text("None Selected")
        case .some(_):
            Text("None Selected")
        }
    }
}
