//
//  WeekSummary.swift
//  WeighWise
//
//  Created by 625098 on 1/14/24.
//

import SwiftUI
import SwiftData

struct WeekSummaryView: View {
    @Environment(\.modelContext) private var context
    @Query var weights: [DateEntry] = []
    @Query var goal: [Goal] = []
    @State private var counter = 0
    @State var weightDelta: Float = 0
    @State var weightDirection: GoalDirection = .WeightGain
    @State private var priorWeight: Float = 0
    @State private var newWeight: Float = 0
    
    @State private var showHeroMessage: Bool = false
    @State private var showWeightDeltaRaw: Bool = false
    @State private var showWeightDelta: Bool = false
    @State private var showNextButton: Bool = false
    var callback: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                if !showWeightDeltaRaw {
                    Spacer()
                }
                Text("Nice, you logged every day!")
                    .font(.custom("JapandiRegular", size: 25))
                    .foregroundStyle(.japandiDarkGray)
                    .padding(.top, 60)
                    .opacity(showHeroMessage ? 1 : 0)
                
                Spacer()
                HStack {
                    Spacer()
                }
                .onAppear {
                    counter += 1
                }
            }
            .background(.japandiOffWhite)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if goal.isEmpty {
                        Text("No goal setup")
                            .font(.custom("JapandiRegular", size: 20))
                            .foregroundStyle(.japandiDarkGray)
                            .padding(.top, 50)
                    } else {
                        ZStack {
                            VStack {
                                WeightChange(goalDirection: weightDirection, weightChange: weightDelta)
                                    .opacity(showWeightDelta ? 1 : 0)
                            }
                            .padding(.bottom, 200)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Text("\(formatFloat(priorWeight))")
                        .font(.custom("JapandiRegular", size: 20))
                    Image(systemName: "arrow.right").font(.custom("", size: 10))
                    Text("\(formatFloat(newWeight))")
                        .font(.custom("JapandiRegular", size: 20))
                        .foregroundColor(getNewWeightColor())
                }
                .opacity(showWeightDelta ? 1 : 0)
                .padding(.top, 200)
                
                Button() {
                    callback()
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.custom("JapandiRegular", fixedSize: 20))
                        .kerning(2)
                        .foregroundColor(.japandiDarkGray)
                }
                .cornerRadius(.infinity)
                .frame(width: 250, height: 45)
                .buttonStyle(.borderedProminent)
                .tint(.japandiLightBrown)
                .padding(.top, 20)
                .opacity(showNextButton ? 1 : 0)
                
                Spacer()
            }
            .onAppear {
                seedGoal()
                generateSummary()
                
                withAnimation(.easeIn(duration: 0.25)) {
                    showHeroMessage.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        showWeightDeltaRaw.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        showWeightDelta.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        showNextButton.toggle()
                    }
                }
            }
            EmptyView().confettiCannon(counter: $counter, colors: [.japandiMintGreen, .japandiRed, .japandiYellow])
                .onAppear {
                    counter += 1
                }
        }
        
    }
    
    func getNewWeightColor() -> Color {
        return weightDirection == (!goal.isEmpty ? goal.first!.goalDirection : .WeightGain) ? .japandiDarkGreen : .japandiRed
    }
    
    func seedGoal() -> Void {
        let goal = Goal(135, .WeightGain, 0.8)
        context.insert(goal)
    }
    
    func generateSummary() -> Void {
        let calendar = Calendar.current
        
        if let weekAverage = try? calculateAverage(of: getCurrentWeeksWeights(weights)) {
            let lastWeekHasWeightsLogged = weights.contains { calendar.startOfDay(for: $0.date) < getSunday(for: Date())}
            if lastWeekHasWeightsLogged {
                let weightToCompareTo = lastWeekHasWeightsLogged ?  getLastWeeksAverage() : weekAverage
                let weightDelta_ = weekAverage - weightToCompareTo
                priorWeight = weightToCompareTo
                newWeight = weekAverage
                weightDelta = abs(weightDelta_)
                weightDirection = weightDelta_ < 0 ? .WeightLoss : .WeightGain
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
        let lastWeeksWeights = weights.filter { calendar.startOfDay(for: $0.date) > calendar.startOfDay(for: lastWeeksSunday) && $0.date < calendar.startOfDay(for: lastWeeksSaturday)}
        
        return calculateAverage(of: lastWeeksWeights)
    }
}

#Preview {
    WeekSummaryView {}
        .modelContainer(for: [Goal.self, DateEntry.self], inMemory: true)
}
