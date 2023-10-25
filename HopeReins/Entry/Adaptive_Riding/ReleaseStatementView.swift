//
//  ReleaseStatementView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct ReleaseStatementView: View {
    @Environment(\.modelContext) var modelContext
    @State private var selectedFileData: Data? = nil
    @State var selectedPatient: Patient? = nil
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FileUploadView(selectedFileData: $selectedFileData, selectedPatient: $selectedPatient)
                HStack {
                    Spacer()
                    if let data = selectedFileData, let patient = selectedPatient {
                        Button("Save") {
                            let releaseStatement = PatientFile(data: data, fileType: "ReleaseStatement")
                            modelContext.insert(releaseStatement)
                            patient.files.append(releaseStatement)
                            releaseStatement.patient = patient
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .navigationTitle("Release Statement")
        }
    }
}

#Preview {
    RidingFormView(rideFormType: .releaseStatement)
}
