//
//  ProfileLoginView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/30/23.
//

import SwiftUI

struct ProfileLoginView: View {
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
            if user.isAdmin {
                Image(systemName: "lock.shield.fill")
                    .font(.title)
            }
            Spacer()
        }
        .padding()
    }
}
