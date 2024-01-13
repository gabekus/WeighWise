//
//  WeightCalendarWeekView.swift
//  WeighWise
//
//  Created by 625098 on 1/11/24.
//

import SwiftUI

struct WeekBubble: View {
    var averageWeight: Float
    var weights: [Weight]
    
    var body: some View {
        RoundedRectangle(cornerRadius: .infinity)
            .fill(.japandiLightBrown)
            .overlay (
                HStack {
                    Spacer()
                    Text(formatWeight(averageWeight))
                        .font(.custom("JapandiBold", size: 20))
                        .foregroundColor(.japandiDarkGray)
                    //            ForEach(1...7, id: \.self) { i in
                    //                    DayBubble(dayOfWeek: i, weight: weights[i-1])
                    //            }
                    Spacer()
                }
            )
            .frame(width: 325, height: 50)
    }
}
    
    #Preview {
        WeekBubble(averageWeight: 125, weights: [])
    }
