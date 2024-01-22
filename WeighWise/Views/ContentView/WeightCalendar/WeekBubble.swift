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
    var dateEntries: [DateEntry]
    
    var isFullWeek: Bool
//    var didMeetGoal: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .infinity)
                .fill(isFullWeek ? .japandiMintGreen : isDayInCurrentWeek(dateEntries.first!.date) ? .japandiLightBrown : .japandiRed)
                .overlay (
                    ZStack {
                        HStack {
                            Text((formatDate(dateEntries.first!.date)))
                                .padding(.leading, datePadding)
                                .foregroundColor(.japandiGray)
                                .font(.custom("JapandiRegular", size: 13))
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text(formatFloat(averageWeight))
                                .font(.custom("JapandiRegular", size: 20))
                            Spacer()
                        }
                        .foregroundColor(.japandiDarkGray)
                        
//                        HStack {
//                            Spacer()
//                            Text("lbs").font(.custom("JapandiRegular", size: 10))
//                                .kerning(1)
//                                .padding(.leading, 50)
//                                .padding(.top, 5)
//                            Spacer()
//                        }
//                        .foregroundColor(.japandiDarkGray)
                        
                        HStack {
                            Spacer()
                            Text(formatDate(dateEntries.last!.date))
                                .padding(.trailing, datePadding)
                                .font(.custom("JapandiRegular", size: 13))
                                .foregroundColor(.japandiGray)
                        }
                    }
                )
                .frame(width: 325, height: 50)
            
//            if didMeetGoal {
//                Image(systemName: "trophy.fill")
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                    .padding(.trailing, 7)
//            }
        }
    }
    
    func isDayInCurrentWeek(_ date: Date) -> Bool {
        return getSunday(for: Date()) == getSunday(for: date)
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
        
        return formattedDate + suffix
    }

}

#Preview {
    WeekBubble(averageWeight: 125, dateEntries: [], isFullWeek: false)
}
