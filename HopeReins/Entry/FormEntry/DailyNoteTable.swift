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
    @State var tableData: [DailyNoteTableCell] = []
    
    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
        if combinedString.wrappedValue.isEmpty {
            self._tableData = State(initialValue: self.createInitialTableData())
        } else {
            self._tableData = State(initialValue: self.combineTableData(combinedString: self.combinedString))
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Grid(alignment: .center) {
                GridRow {
                    Text("#")
                        .frame(minWidth: 75, maxWidth: 200)
                    Text("Code")
                        .frame(minWidth: 75, maxWidth: 200)
                    Text("CPT")
                        .frame(minWidth: 75, maxWidth: 200)
                    Text("O Procedure")
                        .frame(minWidth: 75, maxWidth: 200)
                }
                Divider()
                ForEach(tableData, id: \.id) { rowData in
                    GridRow(alignment: .center) {
                        EntryRowDailyNoteTable(rowData: rowData, tableData: $tableData) {
                            updateCombinedString()
                        }
                        .gridCellColumns(4)
                        .environment(\.isEditable, isEditable)
                    }

                }
            }
            HStack {
                Spacer()
                HStack {
                    Button(action: {
                        addNewRow()
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .buttonStyle(.borderless)
                    Divider()
                    Button(action: {
                        removeLastRow()
                    }, label: {
                        Image(systemName: "minus")
                    })
                    .disabled(!tableData.contains(where: { $0.isEditable }))
                    .buttonStyle(.borderless)
                }
                .bold()
            }
            .padding(.top, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.windowBackground)
                .shadow(radius: 3)
        )
        .frame(minWidth: 300, maxWidth: 800)
        .onChange(of: combinedString) { oldValue, newValue in
            self.tableData = self.combineTableData(combinedString: self.combinedString)
        }
    }
    
    private func addNewRow() {
        let newRow = DailyNoteTableCell(number: 1, code: "00000", cpt: "0", procedire: "Other", isEditable: true)
        tableData.append(newRow)
        updateCombinedString()
    }
    
    private func updateCombinedString() {
        if tableData == initialTableData {
            combinedString = ""
        } else {
            combinedString = tableData.map { $0.combinedStringRepresentation }.joined(separator: "//")
        }
    }
    private func removeLastRow() {
        if let lastIndex = tableData.lastIndex(where: { $0.isEditable }) {
            tableData.remove(at: lastIndex)
            updateCombinedString()
        }
    }
    
    private func createInitialTableData() -> [DailyNoteTableCell] {
        return initialTableData.map { DailyNoteTableCell(number: $0.number, code: $0.code, cpt: $0.cpt, procedire: $0.procedire, isEditable: $0.isEditable, isInitialRow: $0.isInitialRow) }
    }
    
    private func combineTableData(combinedString: String) -> [DailyNoteTableCell] {
        guard !combinedString.isEmpty else {
            return self.createInitialTableData()
        }
        let entries = combinedString.components(separatedBy: "//")
        var tableData: [DailyNoteTableCell] = []
        
        var index = 0
        while index < entries.count {
            let number = entries[index]
            let code = entries[index + 1]
            let cpt = entries[index + 2]
            let procedure = entries[index + 3]
            
            let cellData = DailyNoteTableCell(number: Int(number) ?? 0, code: code, cpt: cpt, procedire: procedure, isEditable: index <= 16 ? false : true)
            tableData.append(cellData)
            
            index += 4
        }
        
        return tableData
    }
    
    var initialTableData: [DailyNoteTableCell] = [
        DailyNoteTableCell(number: 1, code: "PTNEUR15", cpt: "97112", procedire: "PT NEUROMUSCULAR RE_ED 15 MIN", isEditable: false),
        DailyNoteTableCell(number: 1, code: "THERA15", cpt: "97530", procedire: "PT_THEREPEUTIC ACTCTY 15 MIN", isEditable: false),
        DailyNoteTableCell(number: 1, code: "PTGAIT15", cpt: "97116", procedire: "PT GAIT TRAINING 15 MIN", isEditable: false),
        DailyNoteTableCell(number: 1, code: "THEREX", cpt: "97110", procedire: "PT-THEREAPEUTIC EXERCISE 15 MIN", isEditable: false),
        DailyNoteTableCell(number: 1, code: "MANUAL", cpt: "97140", procedire: "PT-MANUAL THERAPY", isEditable: false)
    ]
}

struct EntryRowDailyNoteTable: View {
    @Environment(\.isEditable) var isEditable: Bool
    @ObservedObject var rowData: DailyNoteTableCell
    @Binding var tableData: [DailyNoteTableCell]
    let updateParentCombinedString: () -> Void
    var range: ClosedRange<Int> = 1...9
    var body: some View {
        HStack {
            RestrictedNumberField(range: range, number: $rowData.number)
                .multilineTextAlignment(.center)
                .frame(minWidth: 75, maxWidth: 200)
            
            if rowData.isEditable {
                TextField("Code", text: $rowData.code)
                    .frame(minWidth: 75, maxWidth: 200)
                    .multilineTextAlignment(.center)
            } else {
                Text(rowData.code)
                    .frame(minWidth: 75, maxWidth: 200)
                    .multilineTextAlignment(.center)
            }
            
            if rowData.isEditable {
                TextField("CPT", text: $rowData.cpt)
                    .frame(minWidth: 75, maxWidth: 200)
                    .multilineTextAlignment(.center)
            } else {
                Text(rowData.cpt)
                    .frame(minWidth: 75, maxWidth: 200)
                    .multilineTextAlignment(.center)
            }
            
            if rowData.isEditable {
                TextField("Procedure", text: $rowData.procedire)
                    .frame(minWidth: 75, maxWidth: 200)
                    .multilineTextAlignment(.center)
            } else {
                Text(rowData.procedire)
                    .frame(minWidth: 75, maxWidth: 200)
                    .multilineTextAlignment(.center)
            }
            
        }
        .font(.title3)
        .padding(.pi)
        .onChange(of: rowData.number) { oldValue, newValue in
            updateParentCombinedString()
        }
        .onChange(of: rowData.code) { oldValue, newValue in
            updateParentCombinedString()
        }
        .onChange(of: rowData.cpt) { oldValue, newValue in
            updateParentCombinedString()
        }
        .onChange(of: rowData.procedire) { oldValue, newValue in
            updateParentCombinedString()
        }
    }
}

#Preview {
    DailyNoteTable(combinedString: .constant(""))
}

class DailyNoteTableCell: Identifiable, ObservableObject, Equatable {
    static func == (lhs: DailyNoteTableCell, rhs: DailyNoteTableCell) -> Bool {
        return lhs.number == rhs.number &&
               lhs.code == rhs.code &&
               lhs.cpt == rhs.cpt &&
               lhs.procedire == rhs.procedire
    }
    
    let id = UUID()
    @Published var number: Int
    @Published var code: String
    @Published var cpt: String
    @Published var procedire: String
    var isEditable: Bool
    let isInitialRow: Bool
    
    init(number: Int, code: String, cpt: String, procedire: String, isEditable: Bool = false, isInitialRow: Bool = false) {
        self.number = number
        self.code = code
        self.cpt = cpt
        self.procedire = procedire
        self.isEditable = isEditable
        self.isInitialRow = isInitialRow
    }
    
    var combinedStringRepresentation: String {
        return "\(number)//\(code)//\(cpt)//\(procedire)"
    }
}
