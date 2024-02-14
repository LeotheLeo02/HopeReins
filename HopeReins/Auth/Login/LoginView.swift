//
//  LoginView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/30/23.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \User.username, order: .forward)
    var users: [User]
    @State var adminAccountCreated: Bool = false
    @State var adminUser: User? = nil
    @State var selectedUser: User? = nil
    @FocusState var isFocused: Bool
    @State var password: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                if adminUser == nil {
                    SetupUsersView(adminUser: adminUser)
                } else {
                    Text("Hope Reins EMR Login")
                        .font(.largeTitle.bold())
                    VStack {
                        ForEach(users) { user in
                            Button(action: {
                                withAnimation {
                                    selectedUser = user
                                    isFocused = true
                                }
                            }, label: {
                                ProfileLoginView(selectedUser: $selectedUser, user: user)
                            })
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    
                }
            }
            .padding()
            .onAppear {
                fetchAdminUser()
            }
        }
    }
    func fetchAdminUser() {
        let adminUsers = FetchDescriptor<User>(predicate: #Predicate { user in
            user.isAdmin == true
        })
        adminUser = try? modelContext.fetch(adminUsers).first
    }
}
