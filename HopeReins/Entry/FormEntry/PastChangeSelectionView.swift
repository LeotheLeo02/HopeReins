//
//  PastChangeSelectionView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI

struct PastChangeSelectionView: View {
    @Binding var showPastChanges: Bool
    @Binding var selectedPastChange: PastChange?
    var pastChanges: [PastChange]

    var body: some View {
        Button {
            showPastChanges.toggle()
        } label: {
            HStack {
                Text("\(selectedPastChange?.reason ?? "Current Version")")
                Image(systemName: "chevron.up.chevron.down")
            }
            .fontWeight(.semibold)
        }
        .buttonStyle(.bordered)
        .popover(isPresented: $showPastChanges, attachmentAnchor: .point(UnitPoint.bottom), arrowEdge: .bottom) {
            ScrollView {
                VStack {
                    currentVersionButton
                    ForEach(pastChanges) { pastChange in
                        pastChangeButton(pastChange: pastChange)
                    }
                }
                .padding(5)
            }
        }
    }
    
    private var currentVersionButton: some View {
        Button {
            selectedPastChange = nil
            showPastChanges.toggle()
        } label: {
            HStack {
                if selectedPastChange == nil {
                    Image(systemName: "checkmark")
                        .bold()
                }
                Spacer()
                Text("Current Version")
                    .font(.subheadline)
                Spacer()
            }
            .padding(5)
        }
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder
    func pastChangeButton(pastChange: PastChange) -> some View {
        Button {
            selectedPastChange = pastChange
            showPastChanges.toggle()
        } label: {
            HStack {
                if selectedPastChange == pastChange {
                    Image(systemName: "checkmark")
                        .bold()
                }
                VStack(alignment: .leading) {
                    Text(pastChange.reason)
                        .font(.subheadline)
                    Text("Modified by \(pastChange.author) \(pastChange.date.formatted())")
                        .font(.caption2)
                }
            }
            .padding(5)
        }
        .buttonStyle(.bordered)
        
    }
}
