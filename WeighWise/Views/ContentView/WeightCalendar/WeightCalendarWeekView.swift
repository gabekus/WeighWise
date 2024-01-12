//
//  WeightCalendarWeekView.swift
//  WeighWise
//
//  Created by 625098 on 1/11/24.
//

import SwiftUI

struct WeightCalendarWeekView: View {
    var averageWeight: Float
    var weights: [Weight]
    
    var body: some View {
        HStack {
           Spacer()
            Text(formatWeight(averageWeight))
                .font(.custom("JapandiRegular", size: 20))
                .foregroundColor(.japandiDarkGray)
//            ForEach(1...7, id: \.self) { i in
//                    DayBubble(dayOfWeek: i, weight: weights[i-1])
//            }
            Spacer()
        }
        .frame(width: 325, height: 50)
        .background(.japandiLightBrown)
    }
}

#Preview {
    WeightCalendarWeekView(averageWeight: 125, weights: [])
}
