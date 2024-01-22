//
//  DayBubble.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/31/23.
//

import Foundation
import SwiftUI

struct DayBubble: View {
    @Environment(\.modelContext) private var context
    let diameter: CGFloat = 45
    var dayOfWeek: Int
    var unitDisplay: UnitDisplay
    
    @State private var isPriorWeek = false
    
    @State var dateEntry: DateEntry
    
    var body: some View {
        VStack {
            Text("\(dayOfWeekString(dayOfWeek))")
                .font(.custom("JapandiRegular", size: 8))
                .foregroundColor(Color(isDayCurrentDay(dayOfWeek) ? .japandiMintGreen : .japandiDarkGray))
            Circle()
                .frame(width: diameter)
                .foregroundColor(dateEntry.weight == NONEXISTENT_WEIGHT ? (!isDayOfWeekAfterCurrentDay(dayOfWeek) && !isPriorWeek) || isPriorWeek ? .japandiRed : .japandiLightBrown : .japandiMintGreen)
                .overlay(
                    (getOverlayText())
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
                .font(.custom("JapandiRegular", size: 8))
                .foregroundColor(Color(.japandiDarkGray))
        }
        .onAppear { isPriorWeek = dateEntry.date < getSunday(for: Date()) }
    }
    
    func getOverlayText() -> Text {
        if [nil, NONEXISTENT_CALORIES].contains(dateEntry.calories) || dateEntry.weight == NONEXISTENT_WEIGHT {
            return Text(" ")
        }
            
        return Text(unitDisplay == .Calories ? "\(dateEntry.calories!)" : formatFloat(dateEntry.weight))
            .foregroundColor(Color("JapandiOffWhite"))
            .font(.custom("JapandiRegular", size: 13))
    }
}

func isDayOfWeekAfterCurrentDay(_ day: Int) -> Bool {
    let date = getSunday(for: Date()).addingTimeInterval(TimeInterval((day - 1) * 24 * 60 * 60))
    let result = date.compare(Date()) == .orderedDescending
    return result
}

func isDayCurrentDay(_ day: Int) -> Bool {
    return day == Calendar.current.component(.weekday, from: Date.now)
}


func dayOfWeekString(_ day: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    
    if let date = Calendar.current.date(bySetting: .weekday, value: day, of: Date()) {
        return dateFormatter.string(from: date).first.map(String.init) ?? ""
    }
    return ""
}


