//
//  Weight.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/25/23.
//

import Foundation
import SwiftData

@Model class Weight: Identifiable {
    var date: Date
    var weight: Float
    
    init(_ weight: Float, date: Date = Date()) {
        self.date = Date()
        self.weight = weight
    }
}

