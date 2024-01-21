//
//  Weight.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/25/23.
//

import Foundation
import SwiftData

@Model class DateEntry: Identifiable {
    var date: Date
    var weight: Float
    var calories: Float?
    
    init(_ weight: Float, _ calories: Float?, date: Date = Date()) {
        self.date = Date()
        self.weight = weight
        self.calories = calories
    }
}

