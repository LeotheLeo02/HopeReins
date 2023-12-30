//
//  ResettableProperties.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/29/23.
//

import Foundation

protocol ResettableProperties {
    init()
    init(other: Self)
}
