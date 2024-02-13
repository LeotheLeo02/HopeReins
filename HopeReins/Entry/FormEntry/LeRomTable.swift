//
//  LeRomTable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI
import NaturalLanguage

struct LeRomTable: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State var tableData: [TableCellData] = []

    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
    }

    var body: some View {
        VStack(alignment: .leading) {
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

            ForEach(tableData, id: \.id) { rowData in
                EntryRowView(rowData: rowData, combinedString: $combinedString, tableData: $tableData) {
                    updateCombinedString()
                }
                .environment(\.isEditable, isEditable)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.windowBackground)
                .shadow(radius: 3)
        )
        .frame(maxWidth: 600)
        .onAppear {
            if combinedString.isEmpty {
                self.tableData = self.initialTableData.map { TableCellData(isPain: $0.isPain, label1: $0.label1, value1: $0.value1, value2: $0.value2, value3: $0.value3, value4: $0.value4) }
            } else {
                self.tableData = self.combineTableData(combinedString: self.combinedString)
            }
        }
        
        
        
    }
    private func updateCombinedString() {
        
        if tableData == initialTableData {
            combinedString = ""
        } else {
            combinedString = tableData.map { $0.combinedStringRepresentation }.joined(separator: "//")
        }
        print("Combined String:\(combinedString)")
    }
    
    
    
    
    private func combineTableData(combinedString: String) -> [TableCellData] {
        guard !combinedString.isEmpty else {
            return initialTableData
        }

        var tableData: [TableCellData] = []
        let entries = combinedString.components(separatedBy: "//")

        var index = 0
        while index < entries.count {
            let isPain = entries[index] == "true"
            let label = entries[index + 1]
            
            if isPain {
                let cellData = TableCellData(isPain: true, label1: label, value1: 0, value2: 0, value3: 0.0, value4: 0.0)
                tableData.append(cellData)
                index += 2
            } else {
                let value1 = Int(entries[index + 2]) ?? 1
                let value2 = Int(entries[index + 3]) ?? 1
                let value3 = Double(entries[index + 4]) ?? 0.0
                let value4 = Double(entries[index + 5]) ?? 0.0
                
                let cellData = TableCellData(isPain: false, label1: label, value1: value1, value2: value2, value3: value3, value4: value4)
                tableData.append(cellData)
                index += 6
            }
        }

        return tableData
    }

    let initialTableData: [TableCellData] = [
        TableCellData(label1: "Knee Flexion", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Knee Extension", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Hip Flexion", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Hip Extension", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Hip Abduction", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Hip Internal Rot.", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Hip External Rot.", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Ankle Dorsifl", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Ankle Plantar", value1: 1, value2: 1, value3: 0, value4: 0),
        TableCellData(label1: "Other", value1: 1, value2: 1, value3: 0, value4: 0)
    ]
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
            Button(action: {
                rowData.isPain.toggle()
                updateParentCombinedString()
            }, label: {
                Text("*")
                    .font(.largeTitle)
                    .foregroundColor(rowData.isPain ? .red : .primary)
            })
            .buttonStyle(.borderless)
            
            Text(rowData.label1)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            RestrictedNumberField(range: range, number: $rowData.value1)
                .disabled(rowData.isPain || !isEditable)
            RestrictedNumberField(range: range, number: $rowData.value2)
                .disabled(rowData.isPain || !isEditable)
            DegreeField(degree: $rowData.value3)
                .disabled(rowData.isPain || !isEditable)
            DegreeField(degree: $rowData.value4)
                .disabled(rowData.isPain || !isEditable)
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
        return lhs.isPain == rhs.isPain &&
               lhs.label1 == rhs.label1 &&
               lhs.value1 == rhs.value1 &&
               lhs.value2 == rhs.value2 &&
               lhs.value3 == rhs.value3 &&
               lhs.value4 == rhs.value4
    }
    
    let id = UUID()
    var label1: String
    @Published var isPain: Bool
    @Published var value1: Int
    @Published var value2: Int
    @Published var value3: Double
    @Published var value4: Double

    init(isPain: Bool = false, label1: String, value1: Int, value2: Int, value3: Double, value4: Double) {
        self.isPain = isPain
        self.label1 = label1
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        self.value4 = value4
    }
    
    
    var combinedStringRepresentation: String {
        if isPain {
            // When isPain is true, we only store the label and the pain indicator
            return "\(isPain)//\(label1)"
        } else {
            // When isPain is false, we store all information
            return "\(isPain)//\(label1)//\(value1)//\(value2)//\(value3)//\(value4)"
        }
    }
}

