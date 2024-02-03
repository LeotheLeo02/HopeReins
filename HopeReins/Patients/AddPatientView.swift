//
//  AddPatientView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/10/23.
//

import SwiftUI

struct AddPatientView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var name: String = ""
    @State var mrnString: String = ""
    @State var dateOfBirth: Date = .now

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                PropertyHeader(title: "Name Of Patient")
                TextField("Name...", text: $name)
                    .padding(.vertical, 5)

                PropertyHeader(title: "MRN Number")
                TextField("Enter MRN Number...", text: $mrnString)
                    .onReceive(mrnString.publisher.collect()) {
                        self.mrnString = String($0.prefix(while: { "0123456789".contains($0) }))
                    }
                    .padding(.vertical, 5)

                PropertyHeader(title: "Date Of Birth")
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    .labelsHidden()
                    .padding(.vertical, 5)

                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                    Spacer()
                    Button(action: {
                        if let mrn = Int(mrnString) {
                            let newPatient = Patient(name: name, mrn: mrn, dateOfBirth: dateOfBirth)
                            modelContext.insert(newPatient)
                            dismiss()
                        }
                    }, label: {
                        Text("Add")
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(minWidth: 400, minHeight: 100)
        }
    }
}

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
