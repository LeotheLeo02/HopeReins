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
                VStack(alignment: .leading) {
                    Picker(selection: $settingsType) {
                        Text("Profile")
                            .tag(SettingsType.profile)
                        Text("Data Management")
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
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
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
