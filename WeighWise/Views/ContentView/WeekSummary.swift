//
//  WeekSummary.swift
//  WeighWise
//
//  Created by 625098 on 1/14/24.
//

import SwiftUI
import SwiftData

struct WeekSummaryView: View {
    @Query var weights: [Weight]
    @Query var goal: [Goal]
    @State var weightDelta: Float = 0
    @State var weightDirection: GoalDirection = .WeightGain
    
    var body: some View {
        VStack {
            Text("Nice, you logged every day!")
                .font(.custom("JapandiRegular", size: 20))
                .foregroundStyle(.japandiDarkGray)
                .padding(.top, 50)
            
            if goal.isEmpty {
                Text("No goal setup")
                    .font(.custom("JapandiRegular", size: 20))
                    .foregroundStyle(.japandiDarkGray)
                    .padding(.top, 50)
            } else {
                Text("You \(isGoalMet() ? "met" : "didn't meet") your goal")
            }
            Spacer()
            HStack {
                Spacer()
            }
        }
        .background(.japandiOffWhite)
        .onAppear {
            generateSummary()
        }
    }
    
    func generateSummary() -> Void {
        let calendar = Calendar.current
        
        let goal = goal.first!
        // If goal setup, but no weights before this week's sunday
        // compare to goal.currentWeight
        // else
        // compare to last week's avg weight
        // show weight diff
        
        // if no goal setup
        // show weight diff
        
        
        if let weekAverage = try? calculateAverage(of: getCurrentWeeksWeights(weights)) {
                let lastWeekHasWeightsLogged = weights.contains { calendar.startOfDay(for: $0.date) < getSunday(for: Date())}
                if lastWeekHasWeightsLogged {
                    let weightToCompareTo = lastWeekHasWeightsLogged ?  getLastWeeksAverage() : weekAverage
                    weightDelta = weekAverage - weightToCompareTo
                    weightDirection = weightDelta < 0 ? .WeightLoss : .WeightGain
                    }
                }
    }
    
    func isGoalMet() -> Bool {
        return weightDirection == goal.first!.goalDirection
    }
    
    func getLastWeeksAverage() -> Float {
        let calendar = Calendar.current
        let lastWeeksSaturday = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let lastWeeksSunday = Calendar.current.date(byAdding: .day, value: -13, to: Date())!
        let lastWeeksWeights = weights.filter { calendar.startOfDay(for: $0.date) > calendar.startOfDay(for: lastWeeksSunday) && $0.date < calendar.startOfDay(for: lastWeeksSunday)}
        
        return calculateAverage(of: lastWeeksWeights)
    }
}

#Preview {
    WeekSummaryView()
}
