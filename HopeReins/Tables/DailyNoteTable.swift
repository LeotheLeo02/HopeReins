//
//  DailyNoteTableView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI

struct DailyNoteTable: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State private var tableData: [DailyNoteTableCell]

    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
        self._tableData = State(initialValue: DailyNoteTable.combineTableData(combinedString: combinedString.wrappedValue, initialTableData: DailyNoteTable.initialTableData))
    }

    var body: some View {
        VStack {
            HStack {
                Text("#")
                    .frame(width: 50)
                Divider()
                Text("Code")
                    .frame(width: 100, alignment: .center)
                Divider()
                Spacer()
                Text("CPT")
                    .frame(width: 50, alignment: .leading)
                Divider()
                Spacer()
                Text("O Procedure")
                    .frame(width: 200, alignment: .leading)
                Spacer()
            }
            ForEach(tableData) { rowData in
                EntryRowDailyNoteTable(rowData: rowData, combinedString: $combinedString, tableData: $tableData)
                    .padding(.vertical, 8)
                    .environment(\.isEditable, isEditable)
            }
        }
    }

    private static func combineTableData(combinedString: String, initialTableData: [DailyNoteTableCell]) -> [DailyNoteTableCell] {
        let components = combinedString.components(separatedBy: "//")
        var tableData: [DailyNoteTableCell] = initialTableData

        for (index, component) in components.enumerated() {
            let number = Int(component) ?? 1
            if index < tableData.count {
                tableData[index].number = number
            }
        }

        return tableData
    }
    
    static var initialTableData: [DailyNoteTableCell] = [
        DailyNoteTableCell(number: 1, code: "PTNEUR15", cpt: "97112", procedire: "PT NEUROMUSCULAR RE_ED 15 MIN"),
        DailyNoteTableCell(number: 1, code: "THERA15", cpt: "97530", procedire: "PT_THEREPEUTIC ACTCTY 15 MIN "),
        DailyNoteTableCell(number: 1, code: "PTGAIT15", cpt: "97116", procedire: "PT GAIT TRAINING 15 MIN"),
        DailyNoteTableCell(number: 1, code: "THEREX", cpt: "97110", procedire: "PT-THEREAPEUTIC EXERCISE 15 MIN"),
        DailyNoteTableCell(number: 1, code: "MANUAL", cpt: "97140", procedire: "PT-MANUAL THERABY")
    ]
}

struct EntryRowDailyNoteTable: View {
    @Environment(\.isEditable) var isEditable: Bool
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
                 .disabled(!isEditable)
            
             Text(rowData.code)
                 .frame(width: 100)

             Spacer()

             Text(rowData.cpt)
                 .frame(width: 100)

             Spacer()

             Text(rowData.procedire)
                 .frame(width: 250, alignment: .leading)

             Spacer()
         }
         .font(.title3)
         .padding(.vertical, 8)
    }

    private func updateCombinedString() {
        let updatedString = tableData.map { "\($0.number)" }.joined(separator: "//")
        combinedString = updatedString
        print(combinedString)
    }
}

#Preview {
    DailyNoteTable(combinedString: .constant(""))
}

class DailyNoteTableCell: Identifiable {
    let id = UUID()
    var number: Int
    var code: String
    var cpt: String
    var procedire: String
    
    init(number: Int, code: String, cpt: String, procedire: String) {
        self.number = number
        self.code = code
        self.cpt = cpt
        self.procedire = procedire
    }
}
