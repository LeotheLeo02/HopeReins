//
//  SectionHeader.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import SwiftUI

struct SectionHeader: View {
    var title: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.gray)
        }
        .padding(.vertical)
    }
}
