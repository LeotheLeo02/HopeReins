//
//  SideBarView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/21/23.
//

import SwiftUI
import SwiftData


struct Sidebar: View {
    @Binding var selectedTab: String?
    @State var presentProfileView: Bool = false
    var user: User
    var body: some View {
        VStack {
            List(selection: $selectedTab) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .bold()
                        Text("Account")
                    }
                }
                .tag("Profile")
                Divider()
                ForEach(Tab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.imageName)
                        .tag(tab.rawValue)
                }
            }
        }
    }
}
