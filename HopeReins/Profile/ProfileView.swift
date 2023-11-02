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
                
                switch settingsType {
                case .coreData:
                    CopyPathsView()
                case .profile:
                    VStack {
                        Text(user.username)
                        Button("Log out") {
                            user.isLoggedIn = false
                        }
                    }
                }
            }
            .padding()
        }
    }
}
