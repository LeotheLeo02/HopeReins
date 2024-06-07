//
//  AddPatientView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/10/23.
//

import SwiftUI

struct PropertyHeader: View {
    var title: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.gray)
        }
        .padding(.top, 3.5)
    }
}
