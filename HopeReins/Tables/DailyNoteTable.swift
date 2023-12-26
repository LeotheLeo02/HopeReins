//
//  DailyNoteTableView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI

struct DailyNoteTable: View {
    @Binding var combinedString: String
    @State private var tableData: [DailyNoteTableCell]

    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
        self._tableData = State(initialValue: DailyNoteTable.combineTableData(combinedString: combinedString.wrappedValue, initialTableData: DailyNoteTable.initialTableData))
    }

    var body: some View {
        List {
            HStack {
                Text("#")
                    .frame(width: 50)
                Divider()
                Text("Code")
                    .frame(width: 100, alignment: .center)
                Divider()
                Spacer()
                Text("CPT")
                    .frame(width: 100, alignment: .leading)
                Divider()
                Spacer()
                Text("O Procedure")
                    .frame(width: 100, alignment: .center)
                Spacer()
            }
            ForEach(tableData) { rowData in
                EntryRowDailyNoteTable(rowData: rowData, combinedString: $combinedString, tableData: $tableData)
            }
        }
    }

    private static func combineTableData(combinedString: String, initialTableData: [DailyNoteTableCell]) -> [DailyNoteTableCell] {
        let components = combinedString.components(separatedBy: "//")
        var tableData: [DailyNoteTableCell] = initialTableData

        for (index, component) in components.enumerated() {
            let number = Int(component) ?? 0
            if index < tableData.count {
                tableData[index].number = number
            }
        }

        return tableData
    }
    
    static var initialTableData: [DailyNoteTableCell] = [
        DailyNoteTableCell(number: 1, code: "ABC", cpt: 123, procedire: "Procedure 1"),
        DailyNoteTableCell(number: 1, code: "DEF", cpt: 456, procedire: "Procedure 2"),
    ]
}

struct EntryRowDailyNoteTable: View {
    @State var rowData: DailyNoteTableCell
    @Binding var combinedString: String
    @Binding var tableData: [DailyNoteTableCell]
    var range: ClosedRange<Int> = 1...9
    var body: some View {
        HStack {
            RestrictedNumberField(range: range, number: $rowData.number)
                .onChange(of: rowData.number) { _ in
                    updateCombinedString()
                }
                .frame(width: 50)
            Text(rowData.code)
            Spacer()
            Text("\(rowData.cpt)")
            Spacer()
            Text(rowData.procedire)
            Spacer()
        }
        .padding(.pi)
    }

    private func updateCombinedString() {
        let updatedString = tableData.map { "\($0.number)" }.joined(separator: "//")
        combinedString = updatedString
    }
}

#Preview {
    DailyNoteTable(combinedString: .constant(""))
}

class DailyNoteTableCell: Identifiable {
    let id = UUID()
    var number: Int
    var code: String
    var cpt: Int
    var procedire: String
    
    init(number: Int, code: String, cpt: Int, procedire: String) {
        self.number = number
        self.code = code
        self.cpt = cpt
        self.procedire = procedire
    }
}
