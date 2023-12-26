//
//  MainView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/16/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @SceneStorage("selection") private var selectedTab: String?
    @Environment(\.modelContext) var modelContext
    @State private var isUserLoggedIn: Bool = false
    @Query(sort: \User.username) var users: [User]
    
    init() {
        let predicate = #Predicate<User> { user in
            user.isLoggedIn == true
        }
        _users = Query(filter: predicate, sort: \User.username)
    }
    var body: some View {
        if !users.isEmpty {
            NavigationSplitView(sidebar: {
                Sidebar(selectedTab: $selectedTab, user: users.first!)
                    .frame(minWidth: 250)
            }, detail: {
                DetailView(user: users.first!, selectedTab: $selectedTab)
            })
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            Button("Log In") {
                logIn()
            }
        }
        .padding()
    }

    func logIn() {
        let newUser = User(username: username, password: password)
        modelContext.insert(newUser)
    }
}


struct DetailView: View {
    var user: User
    @Binding var selectedTab: String?
    var body: some View {
        switch selectedTab {
        case "Profile":
            ProfileView(user: user)
        case "Home":
            HomeView()
        case "All Patients":
            PatientsView(user: user)
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
