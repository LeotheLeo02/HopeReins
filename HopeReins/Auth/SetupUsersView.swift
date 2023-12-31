//
//  SetupUsersView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/30/23.
//


import SwiftUI
import SwiftData

struct SetupUsersView: View {
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
                if adminUser == nil {
                    Text("Hope Reins EMR")
                        .font(.largeTitle.bold())
                    CustomSectionHeader(title: "Create Admin Account")
                    SecureField("Password", text: $adminPassword)
                        .textFieldStyle(.roundedBorder)
                    Button("Create Admin Account") {
                        let newAdmin = User(username: "Admin", password: adminPassword, isAdmin: true)
                        modelContext.insert(newAdmin)
                        adminUser = newAdmin
                    }
                }
                CustomSectionHeader(title: "Create Users:")
                CreateUserView()
                CustomSectionHeader(title: "Users:")
                ForEach(users.filter { $0.isAdmin == false }) { user in
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
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical)
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
}

#Preview {
    SetupUsersView()
}

struct CreateUserView: View {
    @Environment(\.modelContext) var modelContext
    @State var username: String = ""
    @State var password: String = ""
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                Button(action: {
                    createUser()
                }, label: {
                    Text("Create User")
                })
            }
        }
    }
    func createUser() {
        let newUser = User(username: username, password: password)
        modelContext.insert(newUser)
        username = ""
        password = ""
    }
}


