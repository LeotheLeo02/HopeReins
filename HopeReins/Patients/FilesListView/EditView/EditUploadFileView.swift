//
//  EditUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/17/23.
//

import SwiftUI

struct EditUploadFileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var fileData: Data?
    @Binding var fileName: String
    var body: some View {
        FileUploadView(selectedFileData: $fileData, fileName: $fileName)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

