//
//  SetupUsersView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/29/23.
//

import SwiftUI
import SwiftData

struct SetupUsersView: View {
    @Environment(\.modelContext) var modelContext
    @State var adminPassword: String = ""
    @State var adminAccountCreated: Bool = false
    @State var showDeleteAlert: Bool = false
    @State var adminUser: User? = nil
    @State var selectedUser: User? = nil
    @Query(sort: \User.username, order: .forward)
    var users: [User]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Hope Reins EMR")
                    .font(.largeTitle.bold())
                if !adminAccountCreated {
                    CustomSectionHeader(title: "Create Admin Account")
                    SecureField("Password", text: $adminPassword)
                        .textFieldStyle(.roundedBorder)
                    Button("Create Admin Account") {
                        let newAdmin = User(username: "Admin", password: adminPassword, isAdmin: true)
                      modelContext.insert(newAdmin)
                      adminUser = newAdmin
                       adminAccountCreated = true
                    }
                }
                CustomSectionHeader(title: "Create Users:")
                CreateUserView()
                ForEach(users.filter { $0.isAdmin == false }) { user in
                    HStack {
                        Label(user.username, systemImage: "person.fill")
                        Spacer()
                        Button(action: {
                            selectedUser = user
                            showDeleteAlert.toggle()
                        }, label: {
                            Text("Delete")
                        })
                    }
                }
            }
            .padding()
            .onAppear {
                let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.isAdmin == true })
                do {
                    adminAccountCreated = ((try modelContext.fetchCount(descriptor))) > 0
                } catch {
                    print(error.localizedDescription)
                }
            }
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
            if let _adminUser = adminUser {
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

struct LoginView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \User.username, order: .forward)
    var users: [User]
    @State var adminAccountCreated: Bool = false
    @State var selectedUser: User? = nil
    @FocusState var isFocused: Bool
    @State var password: String = ""
    var body: some View {
        VStack {
            if !adminAccountCreated {
                SetupUsersView()
            } else {
                VStack {
                    ForEach(users) { user in
                        Button(action: {
                            withAnimation(.bouncy) {
                                selectedUser = user
                                isFocused = true
                            }
                        }, label: {
                            ProfilePasswordEntryView(selectedUser: $selectedUser, user: user)
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()

            }
        }
        .onAppear {
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.isAdmin == true })
            do {
                adminAccountCreated = ((try modelContext.fetchCount(descriptor))) > 0
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}

#Preview {
    LoginView()
}

struct ProfilePasswordEntryView: View {
    @Binding var selectedUser: User?
    @FocusState var isFocused: Bool
    @State var password: String = ""
    var user: User
    var body: some View {
        VStack(alignment: .leading) {
            profileLabel(user: user)
            if selectedUser == user {
                SecureField("Password...", text: $password)
                    .focused($isFocused)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        if password == user.password {
                            user.isLoggedIn = true
                        }
                    }
                    .onAppear {
                        isFocused.toggle()
                    }
            }
        }
    }
    @ViewBuilder func profileLabel(user: User) -> some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 50, height: 50, alignment: .center)
            Text(user.username)
                .bold()
            Spacer()
        }
        .padding()
    }
}
