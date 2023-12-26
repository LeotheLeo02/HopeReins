//
//  LeRomTable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI
import NaturalLanguage

struct LeRomTable: View {
    @State var tableData = [
        TableCellData(label1: "Knee Flexion", value1: 1, value2: 1, value3: 0.0, value4: 0.0),
    ]

    var body: some View {
        List {
            HStack {
                Text("* = pain")
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text("MMT R")
                    .frame(width: 100, alignment: .center)
                Divider()
                Spacer()
                Text("MMT L")
                    .frame(width: 100, alignment: .center)
                Divider()
                Spacer()
                Text("A/PROM (R)")
                    .frame(width: 100, alignment: .center)
                Divider()
                Spacer()
                Text("A/PROM (L)")
                    .frame(width: 100, alignment: .center)
            }
            ForEach(tableData) { rowData in
                EntryRowView(rowData: rowData)
            }
        }
    }
}

struct EntryRowView: View {
    @State var rowData: TableCellData

    var body: some View {
        HStack {
            Text(rowData.label1)
                .bold()
                .frame(width: 100, alignment: .leading)

            RestrictedNumberField(number: $rowData.value1)
            RestrictedNumberField(number: $rowData.value2)
            DegreeField(degree: $rowData.value3)
            DegreeField(degree: $rowData.value4)
        }
    }
}

struct DegreeField: View {
    var range: ClosedRange<Double> = 0...360
    @Binding var degree: Double

    var body: some View {
        HStack {
            TextField("Number", value: Binding(
                get: { self.degree },
                set: {
                    self.degree = min(max($0, range.lowerBound), range.upperBound)
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            Text("°")
        }
    }
}

struct RestrictedNumberField: View {
    @Binding var number: Double
    var range: ClosedRange<Double> = 1...5

    var body: some View {
        TextField("Number", value: Binding(
            get: { self.number },
            set: {
                self.number = min(max($0, range.lowerBound), range.upperBound)
            }
        ), format: .number)
        .textFieldStyle(.roundedBorder)
    }
}

class TableCellData: Identifiable {
    let id = UUID()
    let label1: String
    var value1: Double
    var value2: Double
    var value3: Double
    var value4: Double
    
    init(label1: String, value1: Double, value2: Double, value3: Double, value4: Double) {
        self.label1 = label1
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        self.value4 = value4
    }
}

#Preview {
    LeRomTable()
}
