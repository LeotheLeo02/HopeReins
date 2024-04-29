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
            VStack(alignment: .leading){
                if adminUser == nil || !adminUser!.isLoggedIn {
                    Text("Hope Reins EMR")
                        .font(.largeTitle.bold())
                }
                if adminUser == nil {
                    createAdminAccountView()
                        .padding(.vertical)
                }
                Label("Create Users", systemImage: "person.fill.badge.plus")
                    .font(.title3)
                CreateUserView()
                Label("Users", systemImage: "person.3.fill")
                    .font(.title3)
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
        VStack(alignment: .leading) {
            PropertyHeader(title: "Create Admin Account")
            SecureField("Password", text: $adminPassword)
            HStack {
                Spacer()
                Button("Create Account") {
                    let newAdmin = User(username: "Admin", password: adminPassword, isAdmin: true)
                    modelContext.insert(newAdmin)
                    adminUser = newAdmin
                }
                .disabled(adminPassword.isEmpty)
                .buttonStyle(.borderedProminent)
            }
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
        .padding(.vertical, .pi)
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
                    Text("Add User")
                })
                .buttonStyle(.borderedProminent)
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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


