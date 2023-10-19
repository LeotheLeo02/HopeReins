//
//  CoverLetterView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI

struct CoverLetterView: View {
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
                            let coverLetter = PatientFile(data: data, fileType: "CoverLetter")
                            modelContext.insert(coverLetter)
                            patient.files.append(coverLetter)
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
    CoverLetterView()
}
