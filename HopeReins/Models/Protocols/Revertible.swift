//
//  Revertible.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/29/23.
//

import Foundation
import SwiftData

protocol Revertible {
    associatedtype PropertiesType: ResettableProperties
    var properties: PropertiesType { get set }
    var medicalRecordFile: MedicalRecordFile { get set }
}

extension Revertible {
    func updateMedicalRecordFileName(value: CodableValue) {
        self.medicalRecordFile.fileName = value.stringValue
        modifyMedicalRecord()
    }
    
    func modifyMedicalRecord() {
        self.medicalRecordFile.digitalSignature.modified()
    }
}
