//
//  WeekView.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/31/23.
//

import Foundation
import SwiftUI
import SwiftData

enum UnitDisplay {
    case Weight
    case Calories
}

struct WeekView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @Query private var dateEntries: [DateEntry] = []
    @State private var currentWeeksDateEntries: [DateEntry] = []
    @State private var weekAverageWeight: Float = 0
    @State private var weekAverageCalories: Int = 0
    @State private var headerText: String = ""
    @State private var unitDisplay: UnitDisplay = .Weight
    
    var pastWeights: [DateEntry] = []
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if !currentWeeksDateEntries.isEmpty {
                        ForEach(1...7, id: \.self) { i in
                            DayBubble( dayOfWeek: i, unitDisplay: unitDisplay, dateEntry: currentWeeksDateEntries.indices.contains(i - 1) ? currentWeeksDateEntries[i - 1] : DateEntry(NONEXISTENT_WEIGHT, NONEXISTENT_CALORIES))
                            
                        }
                    }
                    Spacer()
                }.onAppear {
                    do {
                        if pastWeights.isEmpty {
                            var currentWeeksWeightsResult = try getCurrentWeeksWeights(dateEntries)
                            currentWeeksDateEntries = []
                            for i in 1...7 {
                                if currentWeeksWeightsResult.contains(where: { i ==  Calendar.current.component(.weekday, from: $0.date)}) {
                                    currentWeeksDateEntries.append(currentWeeksWeightsResult.removeFirst())
                                } else {
                                    currentWeeksDateEntries.append(DateEntry(NONEXISTENT_WEIGHT, NONEXISTENT_CALORIES))
                                }
                            }
                        } else {
                            currentWeeksDateEntries = pastWeights
                        }
                        let newWeekAverageWeight = calcAverageWeight(of: currentWeeksDateEntries)
                        let newWeekAverageCalories = calcAverageCalories(of: currentWeeksDateEntries)
                        weekAverageWeight = newWeekAverageWeight
                        weekAverageCalories = newWeekAverageCalories
                        
                        if pastWeights.isEmpty {
                            headerText = "This Week's Average"
                        } else {
                            headerText = "\(formatDate(getSunday(for: pastWeights.first!.date)))"
                        }
                    } catch {
                        print("Error \(error)")
                    }
                }
                .onChange(of: scenePhase) {
                    do {
                        if currentWeeksDateEntries.isEmpty {
                            var currentWeeksWeightsResult = try getCurrentWeeksWeights(dateEntries)
                            currentWeeksDateEntries = []
                            for i in 1...7 {
                                if currentWeeksWeightsResult.contains(where: { i ==  Calendar.current.component(.weekday, from: $0.date)}) {
                                    currentWeeksDateEntries.append(currentWeeksWeightsResult.removeFirst())
                                } else {
                                    currentWeeksDateEntries.append(DateEntry(NONEXISTENT_WEIGHT, NONEXISTENT_CALORIES))
                                }
                            }
                        }
                        weekAverageWeight = calcAverageWeight(of: currentWeeksDateEntries)
                        weekAverageCalories = calcAverageCalories(of: currentWeeksDateEntries)
                    } catch {
                        print("Error \(error)")
                    }
                }
                
                
                Spacer()
            }
            .background(.japandiOffWhite)
            
            VStack {
                Text(headerText)
                    .font(.custom("JapandiRegular", size: 25))
                    .foregroundColor(.japandiDarkGray)
                    .padding(50)
                    .kerning(1)
                HStack {
                    Text(unitDisplay == .Weight ? formatFloat(weekAverageWeight) : "\(weekAverageCalories)")
                        .font(.custom("JapandiBold", size: 85))
                    +
                    Text("\(unitDisplay == .Weight ? " lbs" : "cals")")
                        .font(.custom("JapandiRegular", size: 18))
                        .kerning(1)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .onTapGesture { swapUnits() }
                .sensoryFeedback(.success, trigger: unitDisplay)
                .foregroundColor(.japandiDarkGray)
                Spacer()
            }
        }
    }
    
    func swapUnits() {
        unitDisplay = unitDisplay == .Weight ? .Calories : .Weight
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}

func calcAverageWeight(of array: [DateEntry]) -> Float {
    let nonNilWeights = array.compactMap { $0.weight > 0 ? $0.weight : nil }
    let average = nonNilWeights.isEmpty ? nil : nonNilWeights.reduce(0, +) / Float(nonNilWeights.count)
    
    return average ?? 0
}

func calcAverageCalories(of array: [DateEntry]) -> Int {
    let nonNilCalories: [Int] = array.compactMap {
        guard let calories = $0.calories else {
            return nil
        }
        
        return calories > 0 ? calories : nil
    }
    let average = nonNilCalories.isEmpty ? nil : nonNilCalories.reduce(0, +) / nonNilCalories.count
    
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
