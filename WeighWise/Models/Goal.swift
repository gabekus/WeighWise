//
//  Weight.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/25/23.
//

import Foundation
import SwiftData

@Model class Goal: Identifiable {
    var startingWeight: Float
    var goalDirection: GoalDirection
    var goalPoundsPerWeek: Float
    
    init(_ startingWeight: Float, _ goalDirection: GoalDirection, _ goalPoundsPerWeek: Float) {
        self.startingWeight = startingWeight
        self.goalDirection = goalDirection
        self.goalPoundsPerWeek = goalPoundsPerWeek
    }
}

