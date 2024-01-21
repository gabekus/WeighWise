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
    @Query private var weights: [DateEntry] = [DateEntry(5, 5)]
    @State private var currentWeeksWeights: [DateEntry] = []
    @Environment(\.scenePhase) private var scenePhase
    @State private var weekAverage: Float = 0
    
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
                            var currentWeeksWeightsResult = try getCurrentWeeksWeights(weights)
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
                    } catch {
                        print("Error \(error)")
                    }
                }
                .onChange(of: scenePhase) {
                    do {
                        if currentWeeksWeights.isEmpty {
                            var currentWeeksWeightsResult = try getCurrentWeeksWeights(weights)
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
                Text("This Week's Average").font(.custom("JapandiRegular", size: 25)).foregroundColor(.japandiDarkGray)
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
        return calendar.date(byAdding: .day, value: -daysToSunday, to: date) ?? date
    }
    
    return calendar.startOfDay(for: date)
}

let formatFloat = { (_ flt: Float) -> String in String(format: "%.1f", flt)}

func getCurrentWeeksWeights(_ weights: [DateEntry]) throws -> [DateEntry] {
    return weights.filter { $0.date >= getSunday(for: Date()) }
}


#Preview {
    WeekView()
        .modelContainer(for: DateEntry.self, inMemory: true)
}
