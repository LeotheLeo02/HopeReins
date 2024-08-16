//
//  PastChangeSelectionView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI

struct PastChangeSelectionView: View {
    @Binding var showPastChanges: Bool
    @Binding var selectedVersion: Version?
    var pastVersions: [Version]
    
    var body: some View {
        Button {
            showPastChanges.toggle()
        } label: {
            HStack {
                Text("\(selectedVersion?.reason ?? "Current Version")")
                Image(systemName: "chevron.up.chevron.down")
            }
            .fontWeight(.semibold)
        }
        .buttonStyle(.bordered)
        .popover(isPresented: $showPastChanges, attachmentAnchor: .point(UnitPoint.bottom), arrowEdge: .bottom) {
            ScrollView {
                VStack {
                    currentVersionButton
                    ForEach(pastVersions.sorted { $0.date > $1.date }) { pastVersion in
                        pastChangeButton(pastVersion: pastVersion)
                    }
                }
                .padding(5)
            }
        }
    }
    
    private var currentVersionButton: some View {
        Button {
            selectedVersion = nil
            showPastChanges.toggle()
        } label: {
            HStack {
                if selectedVersion == nil {
                    Image(systemName: "checkmark")
                        .bold()
                    
                }
                VStack(alignment: .leading) {
                    Text("Current Version")
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding(5)
        }
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder
    func pastChangeButton(pastVersion: Version) -> some View {
        Button {
            selectedVersion = pastVersion
            showPastChanges.toggle()
        } label: {
            HStack {
                if selectedVersion == pastVersion {
                    Image(systemName: "checkmark")
                        .bold()
                }
                VStack(alignment: .leading) {
                    Text(pastVersion.reason)
                        .font(.subheadline)
                    Text("Modified by \(pastVersion.author) \(formatDate(pastVersion.date))")
                        .font(.caption2)
                }
            }
            .padding(5)
        }
        .buttonStyle(.bordered)
        
    }
}
