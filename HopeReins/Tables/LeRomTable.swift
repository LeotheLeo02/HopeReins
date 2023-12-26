//
//  LeRomTable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI
import NaturalLanguage

struct LeRomTable: View {
    @Binding var combinedString: String
    @State private var tableData: [TableCellData]

    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
        self._tableData = State(initialValue: LeRomTable.combineTableData(combinedString: combinedString.wrappedValue))
    }

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
                EntryRowView(rowData: rowData, combinedString: $combinedString, tableData: $tableData)
            }
        }
    }

    private static func combineTableData(combinedString: String) -> [TableCellData] {
        let components = combinedString.components(separatedBy: "//")
        var tableData: [TableCellData] = initialTableData

        for index in stride(from: 0, to: components.count, by: 5) {
            let label = components[index]
            let value1 = Int(components[index + 1]) ?? 0
            let value2 = Int(components[index + 2]) ?? 0
            let value3 = Double(components[index + 3]) ?? 0
            let value4 = Double(components[index + 4]) ?? 0

            if let existingData = tableData.first(where: { $0.label1 == label }) {
                existingData.value1 = value1
                existingData.value2 = value2
                existingData.value3 = value3
                existingData.value4 = value4
            } else {
                let cellData = TableCellData(label1: label, value1: value1, value2: value2, value3: value3, value4: value4)
                tableData.append(cellData)
            }
        }

        return tableData
    }
    
    static var initialTableData: [TableCellData] = [
        TableCellData(label1: "Knee Flexion", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Knee Extension", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Hip Flexion", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Hip Extension", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Hip Abduction", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Hip Internal Rot.", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Hip External Rot.", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Ankle Dorsifl", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Ankle Plantar", value1: 0, value2: 0, value3: 0, value4: 0),
        TableCellData(label1: "Other", value1: 0, value2: 0, value3: 0, value4: 0)
    ]
}

struct EntryRowView: View {
    @State var rowData: TableCellData
    @Binding var combinedString: String
    @Binding var tableData: [TableCellData]
    var range: ClosedRange<Int> = 1...5
    var body: some View {
        HStack {
            Text(rowData.label1)
                .bold()
                .frame(width: 100, alignment: .leading)

            RestrictedNumberField(range: range, number: $rowData.value1)
            RestrictedNumberField(range: range, number: $rowData.value2)
            DegreeField(degree: $rowData.value3)
            DegreeField(degree: $rowData.value4)
                .onChange(of: rowData.value1) { _ in
                    updateCombinedString()
                }
        }
        .padding(.pi)
    }

    private func updateCombinedString() {
        let updatedString = tableData.map { "\($0.label1)//\($0.value1)//\($0.value2)//\($0.value3)//\($0.value4)" }.joined(separator: "//")
        combinedString = updatedString
    }
}

struct DegreeField: View {
    var range: ClosedRange<Double> = 0...360
    @Binding var degree: Double

    var body: some View {
        HStack {
            TextField("Degrees", value: Binding(
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
    var range: ClosedRange<Int>
    @Binding var number: Int

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
    var label1: String
    var value1: Int
    var value2: Int
    var value3: Double
    var value4: Double
    
    init(label1: String, value1: Int, value2: Int, value3: Double, value4: Double) {
        self.label1 = label1
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        self.value4 = value4
    }
}

#Preview {
    FakeView()
}
