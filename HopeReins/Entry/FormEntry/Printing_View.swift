//
//  Printing_View.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 3/14/24.
//

import SwiftUI

struct Print_Preview: View {
    @ObservedObject var uiManagement: UIManagement
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Image("Logo")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                    HStack {
                        Text(uiManagement.patient!.personalFile.properties["File Name"]!.stringValue)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                        Spacer()
                        Text("DOB: \(uiManagement.patient!.personalFile.properties["Date of Birth"]!.dateValue.formatted(date: .numeric, time: .omitted))")
                            .bold()
                    }
                }
                
                ForEach(uiManagement.dynamicUIElements, id: \.title) { section in
                    sectionContent(section: section)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func sectionContent(section: FormSection) -> some View {
        ForEach(section.elements.map(DynamicUIElementWrapper.init), id: \.id) { wrappedElement in
            DynamicElementView(wrappedElement: wrappedElement.element)
                .environment(\.colorScheme, .light)
                .padding(.top)
        }
    }
}
