//
//  DayBubble.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/31/23.
//

import Foundation
import SwiftUI

struct DayBubble: View {
    let diameter: CGFloat = 45
    var dayOfWeek: Int
    
    @State var weight: Weight
    
    var body: some View {
        VStack {
                Text("\(dayOfWeekString(dayOfWeek))")
                    .font(.custom("JapandiRegular", size: 8))
                    .foregroundColor(Color(isDayCurrentDay(dayOfWeek) ? "JapandiGreen" : "JapandiLightGray"))
            Circle()
                .frame(width: diameter)
                .foregroundColor(Color(weight.weight == NONEXISTENT_WEIGHT ? isDayOfWeekBeforeCurrentDay(dayOfWeek) ? "JapandiRed" : "JapandiLightBrown" : "JapandiGreen"))
                .overlay(
                    (weight.weight == NONEXISTENT_WEIGHT ? Text(" ") : getOverlayText(weight.weight))
                        .overlay(
                            GeometryReader { geometry in
                                Path { path in
                                    let center = CGPoint(x: (geometry.size.width / 2) + diameter / 2, y: geometry.size.height / 2)
                                    path.move(to: center)
                                    path.addLine(to: CGPoint(x: 55, y: 10))
                                }
                                .stroke(.gray.opacity(0.3), lineWidth: dayOfWeek < 7 ? 0.75 : 0)
                            }
                        )
                )
        }
    }
}

func isDayOfWeekBeforeCurrentDay(_ day: Int) -> Bool {
    let date = getSunday().addingTimeInterval(TimeInterval(day * 24 * 60 * 60))
    print("\(day) is before now")
    print("\(date) is before now")
    return date.compare(Date()) == .orderedAscending
}

func isDayCurrentDay(_ day: Int) -> Bool {
    return day == Calendar.current.component(.weekday, from: Date.now)
}

func getOverlayText(_ weight: Float) -> Text {
    return Text("\(formatWeight(weight))")
        .foregroundColor(Color("JapandiOffWhite"))
        .font(.custom("JapandiRegular", size: 19))
}

func dayOfWeekString(_ day: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"

    if let date = Calendar.current.date(bySetting: .weekday, value: day, of: Date()) {
        return dateFormatter.string(from: date).first.map(String.init) ?? ""
    }
    return ""
}


