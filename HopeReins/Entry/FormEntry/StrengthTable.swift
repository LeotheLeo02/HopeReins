//
//  LeRomTable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI

struct StrengthTable: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State var tableData: [TableCellData] = []
    var customLabels: [String]

    init(combinedString: Binding<String>, customLabels: [String]) {
        self._combinedString = combinedString
        self.customLabels = customLabels
        self.tableData = self.createInitialTableData(with: customLabels)
    }

    var body: some View {
        VStack(alignment: .center) {
            Grid(alignment: .center)  {
                GridRow {
                        Text("* = pain")
                        .frame(minWidth: 100, maxWidth: 200)
                        Text("MMT R")
                        .frame(minWidth: 100, maxWidth: 200)
                        Text("MMT L")
                        .frame(minWidth: 100, maxWidth: 200)
                        Text("A/PROM (R)")
                        .frame(minWidth: 100, maxWidth: 200)
                        Text("A/PROM (L)")
                        .frame(minWidth: 100, maxWidth: 200)
                }
                Divider()
                ForEach(tableData, id: \.id) { rowData in
                    GridRow(alignment: .center) {
                        EntryRowView(rowData: rowData, combinedString: $combinedString, tableData: $tableData) {
                            updateCombinedString()
                        }
                        .gridCellColumns(5)
                        .environment(\.isEditable, isEditable)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.windowBackground)
                .shadow(radius: 3)
        )
        .frame(minWidth: 500, maxWidth: 1000)
        .onAppear {
            if combinedString.isEmpty {
                self.tableData = self.createInitialTableData(with: customLabels)
            } else {
                self.tableData = self.combineTableData(combinedString: self.combinedString)
            }
        }
        .onChange(of: combinedString) { oldValue, newValue in
            self.tableData = self.combineTableData(combinedString: self.combinedString)
        }

        
        
        
    }
    private func updateCombinedString() {
        
        if tableData == self.createInitialTableData(with: customLabels) {
            combinedString = ""
        } else {
            combinedString = tableData.map { $0.combinedStringRepresentation }.joined(separator: "//")
        }
        print("Combined String:\(combinedString)")
    }
    
    
    private func createInitialTableData(with labels: [String]) -> [TableCellData] {
        return labels.enumerated().map { index, label in
            TableCellData(label1: label, value1: "", value2: "", value3: "", value4: "")
        }
    }
    
    private func combineTableData(combinedString: String) -> [TableCellData] {
        guard !combinedString.isEmpty else {
            return self.createInitialTableData(with: customLabels)
        }

        var tableData: [TableCellData] = []
        let entries = combinedString.components(separatedBy: "//")

        var index = 0
        while index < entries.count {
            let label = entries[index]
            let value1 = entries[index + 1]
            let value2 = entries[index + 2]
            let isPainValue3 = Bool(entries[index + 3]) ?? false
            let value3 = entries[index + 4]
            let isPainValue4 = Bool(entries[index + 5]) ?? false
            let value4 = entries[index + 6]
            
            let cellData = TableCellData(label1: label, value1: value1, value2: value2, isPainValue3: isPainValue3, value3: value3, isPainValue4: isPainValue4, value4: value4)
            tableData.append(cellData)
            index += 7
        }

        return tableData
    }
}

struct EntryRowView: View {
    @Environment(\.isEditable) var isEditable: Bool
    @ObservedObject var rowData: TableCellData
    @Binding var combinedString: String
    @Binding var tableData: [TableCellData]
    let updateParentCombinedString: () -> Void
    var range: ClosedRange<Int> = 1...5
    var body: some View {
            HStack {
                HStack(alignment: .center) {
                    Text(rowData.label1)
                        .font(.subheadline)
                }
                .frame(minWidth: 100, maxWidth: 200)
                
                StrengthPickerView(value: $rowData.value1)
                    .disabled(!isEditable)
                StrengthPickerView(value: $rowData.value2)
                    .disabled(!isEditable)
                HStack {
                    TextField("", text: $rowData.value3)
                    Button(action: {
                        rowData.isPainValue3.toggle()
                        updateParentCombinedString()
                    }, label: {
                        Text("*")
                            .font(.title)
                            .foregroundColor(rowData.isPainValue3 ? .red : .primary)
                    })
                    .buttonStyle(.borderless)
                }
                .disabled(!isEditable)
                HStack {
                    TextField("", text: $rowData.value4)
                    Button(action: {
                        rowData.isPainValue4.toggle()
                        updateParentCombinedString()
                    }, label: {
                        Text("*")
                            .font(.title)
                            .foregroundColor(rowData.isPainValue4 ? .red : .primary)
                    })
                    .buttonStyle(.borderless)
                }
                .disabled(!isEditable)
                    .onChange(of: rowData.value1) { oldValue, newValue in
                        updateParentCombinedString()
                    }
                    .onChange(of: rowData.value2) { oldValue, newValue in
                        updateParentCombinedString()
                    }
                    .onChange(of: rowData.value3) { oldValue, newValue in
                        updateParentCombinedString()
                    }
                    .onChange(of: rowData.value4) { oldValue, newValue in
                        updateParentCombinedString()
                    }
            }
            .padding(.pi)
    }



}


class TableCellData: Identifiable, ObservableObject, Equatable {
    static func == (lhs: TableCellData, rhs: TableCellData) -> Bool {
        return lhs.label1 == rhs.label1 &&
               lhs.value1 == rhs.value1 &&
               lhs.value2 == rhs.value2 &&
               lhs.isPainValue3 == rhs.isPainValue3 &&
               lhs.isPainValue4 == rhs.isPainValue4
    }
    
    let id = UUID()
    var label1: String
    @Published var value1: String
    @Published var value2: String
    @Published var isPainValue3: Bool
    @Published var value3: String
    @Published var isPainValue4: Bool
    @Published var value4: String

    init(label1: String, value1: String, value2: String, isPainValue3: Bool = false, value3: String, isPainValue4: Bool = false, value4: String) {
        self.label1 = label1
        self.value1 = value1
        self.value2 = value2
        self.isPainValue3 = isPainValue3
        self.value3 = value3
        self.isPainValue4 = isPainValue4
        self.value4 = value4
    }
    
    var combinedStringRepresentation: String {
        // Encode isPainValue3 and isPainValue4 as "true" or "false"
        return "\(label1)//\(value1)//\(value2)//\(isPainValue3)//\(value3)//\(isPainValue4)//\(value4)"
    }
}

