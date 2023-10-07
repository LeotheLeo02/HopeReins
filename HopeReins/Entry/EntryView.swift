//
//  EntryView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/22/23.
//

import SwiftUI
import SwiftData

struct EntryView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Patient.name, order: .forward)
    var patients: [Patient]
    @State var formType: FormType = .physicalTherapy
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $formType) {
                    ForEach(FormType.allCases, id: \.rawValue) { form in
                        Text(form.rawValue)
                            .tag(form)
                    }
                } label: {
                    Label("Form Type:", systemImage: "doc.fill")
                }
                switch formType {
                case .adaptiveRiding:
                    ForEach(RidingFormType.allCases, id: \.rawValue) { rideForm in
                        NavigationLink {
                            RidingFormView(rideFormType: rideForm)
                        } label: {
                            HStack {
                                Spacer()
                                Text(rideForm.rawValue)
                                    .tag(rideForm)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                    }
                case .physicalTherapy:
                    ForEach(PhysicalTherabyFormType.allCases, id: \.rawValue) { phyiscalForm in
                        NavigationLink {
                            PhysicalFormView(physicalFormType: phyiscalForm)
                        } label: {
                            HStack {
                                Spacer()
                                Text(phyiscalForm.rawValue)
                                    .tag(phyiscalForm)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                    }
                }
            }
            .padding()
        }
    }
}




#Preview {
    EntryView()
}
