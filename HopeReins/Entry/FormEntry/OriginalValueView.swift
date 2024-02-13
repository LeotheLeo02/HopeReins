//
//  OriginalValueView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import SwiftUI

struct OriginalValueView: View {
    var id: String
    var value: String
    var displayName: String
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text("Original Value:")
                .foregroundStyle(.gray)
                .font(.caption.bold())
            Text(displayName)
                   .font(.caption2)
                   .bold(displayName != nil)

        }
        .padding(5)
        .onTapGesture(perform: onTap)
    }
    
}
