//
//  EditingView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/17/24.
//

//import SwiftUI
//
//struct EditingView<Record: ChangeRecordable & Revertible>: View where Record.PropertiesType: Reflectable {
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.modelContext) var modelContext
//    @Environment(\.isEditable) var isEditable
//    @State var showChanges: Bool = false
//    @State var changeDescription: String = ""
//    @State var modifiedProperties: Record.PropertiesType
//    @State var pastChangesExpanded: Bool = false
//    @State var initialFileName: String
//    @State var fileName: String = ""
//    @State var record: Record?
//    var username: String
//    var patient: Patient?
//    @State var changeDescripions: [String] = []
//    private var changeDescriptions: [String] {
//
//        let oldFileName = initialFileName
//        let newFileName = fileName
//
//        let fileNameChange = (oldFileName != newFileName) ?
//        "File Name changed from \"\(oldFileName)\" to \"\(newFileName)\"" : ""
//
//        guard let oldProperties = record?.properties as? Reflectable else { return [] }
//
//        var totalChanges = oldProperties.compareProperties(with: modifiedProperties)
////
////        if !fileNameChange.isEmpty {
////            totalChanges.append(fileNameChange)
////        }
//
//        return ["totalChanges"]
//    }
//    
//    var ridingFormType: RidingFormType?
//    var phyiscalFormType: PhysicalTherabyFormType?
//
//
//    @ViewBuilder
//    private var formView: some View {
//        if let _ = modifiedProperties as? RidingLessonProperties {
////            RidingLessonPlanFormView(modifiedProperties: Binding(get: {
////                modifiedProperties as! RidingLessonProperties
////            }, set: {
////                modifiedProperties = $0 as! Record.PropertiesType
////            }), fileName: $fileName)
//        }
//        else if let uploadFileProperties = modifiedProperties as? UploadFileProperties {
////            UploadFileFormView(modifiedProperties: Binding(get: {
////                modifiedProperties as! UploadFileProperties
////            }, set: {
////                modifiedProperties = $0 as! Record.PropertiesType
////            }), fileName: $fileName)
//        }
//    }
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 10) {
//                if record != nil && isEditable {
//                    PastChangesView(modifiedProperties: $modifiedProperties, record: record, fileName: $fileName)
//                }
//                formView
//                
//            }
//            .padding()
//        }
//        .environment(\.isEditable, isEditable)
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button {
//                    dismiss()
//                } label: {
//                    Text((record == nil || !changeDescription.isEmpty) ? "Cancel" : "Done")
//                }
//            }
//            if record == nil {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button(action: {
//                        addFile()
//                        try? modelContext.save()
//                        dismiss()
//                    }, label: {
//                        Text("Save")
//                    })
//                    .buttonStyle(.borderedProminent)
//                }
//            } else if !changeDescriptions.isEmpty {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button {
//                        showChanges.toggle()
//                    } label: {
//                        Text("Apply Changes")
//                    }
//                    .buttonStyle(.borderedProminent)
//                    
//                }
//            }
//        }
//        .sheet(isPresented: $showChanges) {
////            ReviewChangesView(modifiedProperties: $modifiedProperties, record: record, changeDescriptions: changeDescriptions, username: username, fileName: $fileName)
//        }
//        .onAppear {
//            fileName = initialFileName
//        }
//    }
//    
//    func addFile() {
//        switch modifiedProperties {
//        case let properties as RidingLessonProperties:
//            addRidingLessonPlan(properties)
//        case let properties as UploadFileProperties:
//            let fileType = determineFileType()
//            addUploadFile(properties)
//        default:
//            break
//        }
//
//        saveContext()
//    }
//
//
//        private func addRidingLessonPlan(_ properties: RidingLessonProperties) {
//            let medicalRecordFile = createMedicalRecordFile(for: RidingFormType.ridingLessonPlan.rawValue)
//            modelContext.insert(RidingLessonPlan(medicalRecordFile: medicalRecordFile, properties: properties))
//        }
//
//        private func addUploadFile(_ properties: UploadFileProperties) {
//            let fileType = determineFileType()
//            let medicalRecordFile = createMedicalRecordFile(for: fileType)
//            modelContext.insert(UploadFile(medicalRecordFile: medicalRecordFile, properties: properties))
//        }
//
//        private func createMedicalRecordFile(for fileType: String) -> MedicalRecordFile {
//            return MedicalRecordFile(patient: patient!, fileName: fileName, fileType: fileType, digitalSignature: createDigitalSignature())
//        }
//    
//    private func createDigitalSignature() -> DigitalSignature {
//        return DigitalSignature(author: username, modification: FileModification.added.rawValue, dateModified: .now)
//    }
//    
//    private func saveContext() {
//        do {
//            try modelContext.save()
//        } catch {
//            // Handle the error appropriately
//            print("Error saving context: \(error)")
//        }
//    }
//    
//    private func determineFileType() -> String {
//        if let type = ridingFormType {
//            if type == .releaseStatement {
//                return type.rawValue
//            } else if type == .coverLetter {
//                return type.rawValue
//            } else if type == .updateCoverLetter {
//                return type.rawValue
//            }
//        } else {
//            if let type = phyiscalFormType {
//                if type == .referral {
//                    return type.rawValue
//                }
//            }
//        }
//        return ""
//    }
//    
//}
