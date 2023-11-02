//
//  EntryView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/22/23.
//

import SwiftUI

struct EntryView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("selectedFormType") var formTypeRawValue: String = FormType.physicalTherapy.rawValue

    var formType: FormType {
        get { FormType(rawValue: formTypeRawValue) ?? .physicalTherapy }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Picker("Form Type:", selection: $formTypeRawValue) {
                        ForEach(FormType.allCases, id: \.rawValue) { form in
                            Text(form.rawValue).tag(form.rawValue)
                        }
                    }
                    switch formType {
                    case .adaptiveRiding:
                        ForEach(RidingFormType.allCases, id: \.rawValue) { rideForm in
                            NavigationLink {
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
}




#Preview {
    EntryView()
}
