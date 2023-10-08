//
//  ReleaseStatementView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI
import SwiftData

struct ReleaseStatementView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Patient.dateOfBirth, order: .forward)
    var patients: [Patient]
    @State private var selectedFileName: String? = nil
    @State private var selectedFileData: Data? = nil
    @State var selectedPatient: Patient? = nil
    private var selectedImage: Image? {
        if let data = selectedFileData, let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        return nil
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    panel.canChooseFiles = true
                    
                    if panel.runModal() == .OK, let url = panel.url {
                        selectedFileName = url.lastPathComponent
                        do {
                            selectedFileData = try Data(contentsOf: url)
                        } catch {
                            print("Error reading the file: \(error)")
                        }
                    }
                } label: {
                    Label("\((selectedFileName != nil) ? "Change" : "Import") Release Statement File", systemImage: "square.and.arrow.down.fill")
                }
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                }
                Menu {
                    ForEach(patients) { patient in
                        Button {
                            selectedPatient = patient
                        } label: {
                            Text(patient.name)
                        }
                    }
                } label: {
                    Text("Patient: \(selectedPatient?.name ?? "None Selected")")
                }
                HStack {
                    Spacer()
                    if let data = selectedFileData, let patient = selectedPatient {
                        Button("Save") {
                            let releaseStatement = ReleaseStatement(data: data)
                            modelContext.insert(releaseStatement)
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
