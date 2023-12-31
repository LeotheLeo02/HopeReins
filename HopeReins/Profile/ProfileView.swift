//
//  ProfileView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/22/23.
//

import SwiftUI

enum SettingsType {
    case coreData
    case profile
}

struct ProfileView: View {
    @State var settingsType: SettingsType = .profile
    @Environment(\.modelContext) private var modelContext
    var user: User
    var body: some View {
        ScrollView {
            if user.isAdmin {
                VStack {
                    Picker(selection: $settingsType) {
                        Text("Profile")
                            .tag(SettingsType.profile)
                        Text("Data")
                            .tag(SettingsType.coreData)
                    } label: {
                        Text("Settings")
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
                .padding()
            }
            switch settingsType {
            case .coreData:
                CopyPathsView()
            case .profile:
                ProfileInfoView(user: user)
            }
        }
    }
}


struct ProfileInfoView: View {
    var user: User
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(user.username)
                    .font(.largeTitle.bold())
                if user.isAdmin {
                    Image(systemName: "lock.shield.fill")
                        .font(.largeTitle)
                }
                Spacer()
                Button("Log out") {
                    user.isLoggedIn = false
                }
            }
            .padding()
            if user.isAdmin {
                SetupUsersView(adminUser: user)
            }
        }
    }
}
