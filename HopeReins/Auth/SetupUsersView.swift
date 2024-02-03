//
//  SetupUsersView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/30/23.
//


import SwiftUI
import SwiftData

struct SetupUsersView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @State var adminPassword: String = ""
    @State var showDeleteAlert: Bool = false
    @State var adminUser: User?
    @State var selectedUser: User? = nil
    @Query(sort: \User.username, order: .forward)
    var users: [User]
    
    var body: some View {
        ScrollView {
            VStack {
                if adminUser == nil || !adminUser!.isLoggedIn {
                    Text("Hope Reins EMR")
                        .font(.largeTitle.bold())
                }
                if adminUser == nil {
                    createAdminAccountView()
                }
                PropertyHeader(title: "Create Users:")
                CreateUserView()
                PropertyHeader(title: "Users:")
                ForEach(users.filter { $0.isAdmin == false }) { user in
                    userItemLabel(user: user)
                }
            }
            .padding()
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this user? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        modelContext.delete(selectedUser!)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .toolbar {
            if let _adminUser = adminUser, _adminUser.isLoggedIn == false {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        _adminUser.isLoggedIn = true
                    } label: {
                        Text("Done")
                    }
                    
                }
            }
        }
    }
    
    @ViewBuilder
    func createAdminAccountView() -> some View {
        PropertyHeader(title: "Create Admin Account")
        SecureField("Password", text: $adminPassword)
        Button("Create Admin Account") {
            let newAdmin = User(username: "Admin", password: adminPassword, isAdmin: true)
            modelContext.insert(newAdmin)
            adminUser = newAdmin
        }
    }
    
    @ViewBuilder
    func userItemLabel(user: User) -> some View {
        HStack {
            Label(user.username, systemImage: "person.fill")
            Spacer()
            Button {
                selectedUser = user
                showDeleteAlert.toggle()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical)
        Divider()
    }
}


struct CreateUserView: View {
    @Environment(\.modelContext) var modelContext
    @State var username: String = ""
    @State var password: String = ""
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            HStack {
                Spacer()
                Button(action: {
                    createUser()
                }, label: {
                    Label("Create User", systemImage: "person.fill.badge.plus")
                })
            }
        }
        .padding()
    }
    func createUser() {
        let newUser = User(username: username, password: password)
        modelContext.insert(newUser)
        username = ""
        password = ""
    }
}


