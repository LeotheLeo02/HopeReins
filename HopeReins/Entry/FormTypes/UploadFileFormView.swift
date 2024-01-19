//
//  UploadFileFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/17/24.
//

import SwiftUI
import SwiftData

struct UploadFileFormView: View {
    @Binding var modifiedProperties: UploadFileProperties
    @Binding var fileName: String
    var body: some View {
        BasicTextField(title: "File Name...", text: $fileName)
        FileUploadButton(properties: $modifiedProperties)
    }
}
