//
//  WeightChange.swift
//  WeighWise
//
//  Created by 625098 on 1/15/24.
//

import SwiftUI

struct WeightChange: View {
    var goalDirection: GoalDirection
    var weightChange: Float
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "arrow.\(goalDirection == .WeightGain ? "up" : "down")").font(.custom("", size: 18))
            Text("\(formatWeight(weightChange))")
                .font(.custom("JapandiRegular", size: 75))
            + Text(" lbs").font(.custom("JapandiRegular", size: 18))
                .foregroundColor(.japandiDarkGray)
                .kerning(1)
            Spacer()
        }
    }
}
