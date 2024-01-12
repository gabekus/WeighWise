//
//  WeightChartView.swift
//  WeighWiseTest
//
//  Created by 625098 on 1/1/24.
//

import Foundation
import SwiftUI
import Charts
import SwiftData

struct WeightCalendar: View {
    @Environment(\.modelContext) private var context
    @Query private var weights: [Weight]
    
    
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                }
            }
            .background(.japandiOffWhite)
            
            VStack {
                if weights.count > 0 {
                    let viewmodel = getWeightCalendarViewModel(weights)
                    
                    ScrollView {
                        ForEach(Array(viewmodel.keys), id: \.self) { date in
                            WeightCalendarWeekView(averageWeight: viewmodel[date]!.averageWeight, weights: viewmodel[date]!.days)
                            
                        }
                    }
                }
            }
            .onAppear {
                try? context.delete(model: Weight.self)
                seedData()
            }
        }
    }
    
    func seedData() {
        for i in 0...35 {
            let weight = Weight(Float(Int.random(in: 138..<143)))
            weight.date = Calendar.current.date(byAdding: .day, value: -i, to: weight.date)!
            context.insert(weight)
        }
    }
    struct WeightCalendarViewModel {
        let years: [WeightYear]
    }
    
    struct WeightYear: Identifiable {
        let id = UUID()  // Add an identifier to conform to Identifiable
        let year: Int
        let months: [WeightMonth]
    }
    
    struct WeightMonth: Identifiable {
        let id = UUID()  // Add an identifier to conform to Identifiable
        let name: String
        var weeks: [WeightWeek]
    }
    
    struct WeightWeek: Identifiable {
        let id = UUID()  // Add an identifier to conform to Identifiable
        var averageWeight: Float
        var days: [Weight]
    }
    
    func formatYear(_ year: Int) -> String {
        let yearString = String(year)
        return yearString.replacingOccurrences(of: ",", with: "")
    }
    
    func getWeightCalendarViewModel(_ weights: [Weight]) -> [Date: WeightWeek] {
        guard !weights.isEmpty else {
            return [:]
        }
        
        let calendar = Calendar.current
        var sortedWeights = weights.sorted(by: { $0.date > $1.date })
        var weightWeeksWithMetadata = [Date: WeightWeek]()
        
        var priorSunday = getSunday(for: sortedWeights.last!.date)
        
        while !sortedWeights.isEmpty {
            priorSunday = getSunday(for: sortedWeights.last!.date)
            
            if weightWeeksWithMetadata[priorSunday] == nil {
                weightWeeksWithMetadata[priorSunday] = WeightWeek(averageWeight: 0, days: [])
            }
            
            let nextSunday = calendar.date(byAdding: .day, value: 7, to: priorSunday)!
            let weightsForCurrentWeek = sortedWeights.filter { $0.date >= priorSunday && $0.date < nextSunday }
            
            var fullWeek: [Weight] = weightsForCurrentWeek
            if weightsForCurrentWeek.count < 7 {
                let missingWeights = getMissingWeightDays(weightsForCurrentWeek)
                fullWeek += missingWeights
            }
            
            fullWeek.sort { $0.date < $1.date } // Sort weekdays ascending
            let avgWeight = weightsForCurrentWeek.reduce(0.0) { $0 + $1.weight } / Float(weightsForCurrentWeek.count)
            
            weightWeeksWithMetadata[priorSunday]!.days = fullWeek
            weightWeeksWithMetadata[priorSunday]?.averageWeight = avgWeight
            
            
            while !sortedWeights.isEmpty && sortedWeights.last!.date < nextSunday {
                sortedWeights.removeLast()
            }
        }
        
        return weightWeeksWithMetadata
    }
    
    func getMissingWeightDays(_ weightsForWeek: [Weight]) -> [Weight] {
        let calendar = Calendar.current
        let sundayDate = getSunday(for: weightsForWeek.first!.date)
        
        let daysInWeek = (0..<7).map { calendar.date(byAdding: .day, value: $0, to: sundayDate) }
        
        let missingDays = daysInWeek.filter { day in
            !weightsForWeek.contains { weight in
                calendar.isDate(weight.date, inSameDayAs: day ?? Date())
            }
        }
        
        let nonexistentWeights = missingDays.map { Weight(NONEXISTENT_WEIGHT, date: $0 ?? Date()) }
        
        return nonexistentWeights
    }
    
    //    func getWeeksForMonth(month: Date, weights: [Weight]) -> [WeightWeek] {
    //        let calendar = Calendar.current
    //        let monthComponents = calendar.dateComponents([.year, .month], from: month)
    //        guard let firstDayOfMonth = calendar.date(from: monthComponents),
    //              let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) else {
    //            return []
    //        }
    //
    //        var weeks: [WeightWeek] = []
    //
    //        calendar.enumerateDates(startingAfter: firstDayOfMonth, matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: calendar.firstWeekday), matchingPolicy: .nextTime) { (date, _, stop) in
    //            guard let date = date, date <= lastDayOfMonth else {
    //                stop = true
    //                return
    //            }
    //            
    //            let daysInWeek = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: date) }
    //            let weekWeights = daysInWeek.compactMap { day in
    //                weights.first { $0.date == day }
    //            }
    //            let averageWeight = calculateAverageWeight(weekWeights)
    //            let week = WeightWeek(averageWeight: averageWeight, days: weekWeights)
    //            weeks.append(week)
    //        }
    //
    //        return weeks
    //    }
    
    func calculateAverageWeight(_ weights: [Weight]) -> Float {
        return weights.reduce(0.0) { $0 + $1.weight } / Float(weights.filter { $0.weight != NONEXISTENT_WEIGHT}.count)
    }
}

#Preview {
    WeightCalendar()
        .modelContainer(for: Weight.self, inMemory: true)
}
