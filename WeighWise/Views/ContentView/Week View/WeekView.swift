//
//  WeekView.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/31/23.
//

import Foundation
import SwiftUI
import SwiftData

struct WeekView: View {
    @Environment(\.modelContext) private var context
    @Query private var dateEntries: [DateEntry] = []
    @State private var currentWeeksWeights: [DateEntry] = []
    @Environment(\.scenePhase) private var scenePhase
    @State private var weekAverage: Float = 0
    @State private var headerText: String = ""
    
    var pastWeights: [DateEntry] = []
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if !currentWeeksWeights.isEmpty {
                        ForEach(1...7, id: \.self) { i in
                            DayBubble(dayOfWeek: i, dateEntry: currentWeeksWeights.indices.contains(i - 1) ? currentWeeksWeights[i - 1] : DateEntry(NONEXISTENT_WEIGHT, NONEXISTENT_WEIGHT))
                            
                        }
                    }
                    Spacer()
                }.onAppear {
                    do {
                        if pastWeights.isEmpty {
                            var currentWeeksWeightsResult = try getCurrentWeeksWeights(dateEntries)
                            currentWeeksWeights = []
                            for i in 1...7 {
                                if currentWeeksWeightsResult.contains(where: { i ==  Calendar.current.component(.weekday, from: $0.date)}) {
                                    currentWeeksWeights.append(currentWeeksWeightsResult.removeFirst())
                                } else {
                                    currentWeeksWeights.append(DateEntry(NONEXISTENT_WEIGHT, NONEXISTENT_WEIGHT))
                                }
                            }
                        } else {
                            currentWeeksWeights = pastWeights
                        }
                            let newWeekAverage = calculateAverage(of: currentWeeksWeights)
                            weekAverage = newWeekAverage
                        if pastWeights.isEmpty {
                            headerText = "This Week's Average"
                        } else {
                            headerText = "Average For \(formatDate(getSunday(for: pastWeights.first!.date)))"
                        }
                    } catch {
                        print("Error \(error)")
                    }
                }
                .onChange(of: scenePhase) {
                    do {
                        if currentWeeksWeights.isEmpty {
                            var currentWeeksWeightsResult = try getCurrentWeeksWeights(dateEntries)
                            currentWeeksWeights = []
                            for i in 1...7 {
                                if currentWeeksWeightsResult.contains(where: { i ==  Calendar.current.component(.weekday, from: $0.date)}) {
                                    currentWeeksWeights.append(currentWeeksWeightsResult.removeFirst())
                                } else {
                                    currentWeeksWeights.append(DateEntry(NONEXISTENT_WEIGHT, NONEXISTENT_WEIGHT))
                                }
                            }
                        }
                        weekAverage = calculateAverage(of: currentWeeksWeights)
                    } catch {
                        print("Error \(error)")
                    }
                }
                
                
                Spacer()
            }
            .background(.japandiOffWhite)
            
            VStack {
               
                Text(headerText).font(.custom("JapandiRegular", size: 25)).foregroundColor(.japandiDarkGray)
                    .padding(50)
                    .kerning(1)
                HStack {
                    Text("\(formatFloat(weekAverage))").font(.custom("JapandiBold", size: 85))
                    +
                    Text(" lbs").font(.custom("JapandiRegular", size: 18))
                        .kerning(1)
                }
                .foregroundColor(.japandiDarkGray)
                Spacer()
            }
            
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"

        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}


func calculateAverage(of array: [DateEntry]) -> Float {
    let nonNilWeights = array.compactMap { $0.weight > 0 ? $0.weight : nil }
    let average = nonNilWeights.isEmpty ? nil : nonNilWeights.reduce(0, +) / Float(nonNilWeights.count)
    
    return average ?? 0
}

func getSunday(for date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.weekday], from: calendar.startOfDay(for: date))
    
    if let weekday = components.weekday {
        let daysToSunday = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysToSunday, to: date) ?? date)
    }
    
    let sunday = calendar.startOfDay(for: date)
    return sunday
}

func getSaturday(for date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.weekday], from: calendar.startOfDay(for: date))
    
    if let weekday = components.weekday {
        let daysToSaturday = (weekday - calendar.firstWeekday + 1) % 7
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: daysToSaturday, to: date)!) // Force unwrap here
    }
    
    return calendar.startOfDay(for: date)
}


let formatFloat = { (_ flt: Float) -> String in String(format: "%.1f", flt)}

func getCurrentWeeksWeights(_ weights: [DateEntry]) throws -> [DateEntry] { 
    let calendar = Calendar.current
    let sundayDate = getSunday(for: Date())
    let currentWeeksWeights = weights.filter { calendar.startOfDay(for: $0.date) >= sundayDate }
    return currentWeeksWeights
}


#Preview {
    WeekView()
        .modelContainer(for: DateEntry.self, inMemory: true)
}
