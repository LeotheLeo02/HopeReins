//
//  ReleaseStatementView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct ReleaseStatementView: View {
    @Environment(\.modelContext) var modelContext
    @State private var selectedFileName: String? = nil
    @State private var selectedFileData: Data? = nil
    @State var selectedPatient: Patient? = nil
    @State var selectPatient: Bool = false
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
                Button {
                    selectPatient.toggle()
                } label: {
                    Label("\(selectedPatient == nil ? "Select Patient" : "Selected Patient: \(selectedPatient!.name)")", systemImage: "person.fill")
                }
                .sheet(isPresented: $selectPatient) {
                    PatientSelectionView(selection: $selectedPatient)
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
