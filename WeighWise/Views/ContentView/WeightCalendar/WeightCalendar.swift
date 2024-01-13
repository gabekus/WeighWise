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
                Spacer()
            }
            
            VStack {
                if weights.count > 0 {
                    let viewmodel = getWeightCalendarViewModel(weights)
                    HStack {
                        NavigationView {
                            ScrollView {
                                ForEach(viewmodel.sorted(by: { $0.key > $1.key}), id: \.key) { year, months in
                                    Text("\(formatYear(year))")
                                    ForEach(months.sorted(by: { $0.key > $1.key }), id: \.key) { month, weeks in
                                        Text("\(formatMonth(month))")
                                        ForEach(weeks.sorted(by: { $0.key > $1.key}), id: \.key) { week in
                                            Text("\(formatDate(week.value.days.first!.date))")
                                                .multilineTextAlignment(.leading)
                                            NavigationLink(destination: WeekView()) {
                                                WeekBubble(averageWeight: week.value.averageWeight, weights: week.value.days)
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.japandiOffWhite)
                        }
                    }
                }
            }
            
            
            .onAppear {
                //                try? context.delete(model: Weight.self)
                //                seedData()
            }
        }
        .background(.japandiOffWhite)
    }
    
    func seedData() {
        for i in 0...35 {
            let weight = Weight(Float(Int.random(in: 138..<143)))
            weight.date = Calendar.current.date(byAdding: .day, value: -i, to: weight.date)!
            context.insert(weight)
        }
    }
    
    func formatMonth(_ month: Int) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        
        guard let monthName = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: 1)) else {
            return "Invalid Month"
        }
        
        return df.string(from: monthName)
        
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        return dateFormatter.string(from: date)
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
        let id = UUID()
        var averageWeight: Float
        var days: [Weight]
    }
    
    func formatYear(_ year: Int) -> String {
        let yearString = String(year)
        return yearString.replacingOccurrences(of: ",", with: "")
    }
    
    func getWeightCalendarViewModel(_ weights: [Weight]) -> [Int: [Int: [Date: WeightWeek]]] {
        guard !weights.isEmpty else {
            return [:]
        }
        
        let calendar = Calendar.current
        var sortedWeights = weights.sorted(by: { $0.date > $1.date })
        var weightWeeks = [Date: WeightWeek]()
        var weightMonths = [Int: [Date: WeightWeek]]()
        var weightYears = [Int: [Int: [Date: WeightWeek]]]()
        
        var priorSunday = getSunday(for: sortedWeights.last!.date)
        
        while !sortedWeights.isEmpty {
            priorSunday = getSunday(for: sortedWeights.last!.date)
            
            if weightWeeks[priorSunday] == nil {
                weightWeeks[priorSunday] = WeightWeek(averageWeight: 0, days: [])
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
            
            weightWeeks[priorSunday]!.days = fullWeek
            weightWeeks[priorSunday]?.averageWeight = avgWeight
            
            let monthValue = calendar.component(.month, from: priorSunday)
            
            if weightMonths[monthValue] == nil {
                weightMonths[monthValue] = [:]
            }
            
            weightMonths[monthValue]![priorSunday] = weightWeeks[priorSunday]
            
            let year = calendar.component(.year, from: priorSunday)
            if weightYears[year] == nil {
                weightYears[year] = [:]
            }
            
            weightYears[year]![monthValue] = weightMonths[monthValue]
            
            while !sortedWeights.isEmpty && sortedWeights.last!.date < nextSunday {
                sortedWeights.removeLast()
            }
        }
        
        return weightYears
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
    
    func calculateAverageWeight(_ weights: [Weight]) -> Float {
        return weights.reduce(0.0) { $0 + $1.weight } / Float(weights.filter { $0.weight != NONEXISTENT_WEIGHT}.count)
    }
}

#Preview {
    WeightCalendar()
        .modelContainer(for: Weight.self, inMemory: true)
}
