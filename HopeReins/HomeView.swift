//
//  HomeView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/7/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Patient.dateOfBirth, order: .forward)
    var patients: [Patient]
    
    var body: some View {
        NavigationStack {
           Text("Home")
        }
    }
}
