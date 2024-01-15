//
//  WeightCalendarWeekView.swift
//  WeighWise
//
//  Created by 625098 on 1/11/24.
//

import SwiftUI

struct WeekBubble: View {
    private let datePadding: CGFloat = 15
    var averageWeight: Float
    var weights: [Weight]
    
    var isFullWeek: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .infinity)
                .fill(.japandiLightBrown)
                .overlay (
                    ZStack {
                        HStack {
                            Text((formatDate(weights.first!.date)))
                                .padding(.leading, datePadding)
                                .foregroundColor(.japandiGray)
                                .font(.custom("JapandiRegular", size: 13))
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text(formatWeight(averageWeight))
                                .font(.custom("JapandiRegular", size: 20))
                                .foregroundColor(.japandiDarkGray)
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text(formatDate(weights.last!.date))
                                .padding(.trailing, datePadding)
                                .font(.custom("JapandiRegular", size: 13))
                                .foregroundColor(.japandiGray)
                        }
                    }
                )
                .frame(width: 325, height: 50)
            
            if weights.count > 6 {
                Image(systemName: "trophy.fill")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 7)
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
//        dateFormatter.timeZone = TimeZone.current
        
        let day = Calendar.current.component(.day, from: date)
        
        let suffix = switch day {
        case 1, 21, 31: "st"
        case 2, 22: "nd"
        case 3, 23: "rd"
        default: "th"
        }
        
        
        let formattedDate = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "EEEE"
        print("\(dateFormatter.string(from: date)): ", formattedDate)
        
        return formattedDate + suffix
    }

}

#Preview {
    WeekBubble(averageWeight: 125, weights: [], isFullWeek: false)
}
