//
//  OnboardingView.swift
//  WeighWise
//
//  Created by 625098 on 1/9/24.
//

import SwiftUI
import SwiftData

enum OnboardingStep {
    case WeightEntry
    case GoalDirectionEntry
    case GoalPoundsEntry
    case Onboarded
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Query private var goals: [Goal] = []
    @State private var step = OnboardingStep.WeightEntry
    @State private var startingWeight: Float = 0
    @State private var goalDirection: GoalDirection = .WeightGain
    @State private var goalPoundsPerWeek: Float = 0
    
    var body: some View {
        NavigationView {
            VStack {
                switch(step) {
                case .WeightEntry:
                    NumberEntryView(headerText: "Enter current weight") { weight in
                        step = OnboardingStep.GoalDirectionEntry
                        startingWeight = weight
                    }
                    
                case .GoalDirectionEntry:
                    ZStack {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("I'm trying to").font(.custom("JapandiRegular", size: 25)).foregroundColor(.japandiDarkGray)
                                Spacer()
                            }
                            Spacer()
                            Spacer()
                        }
                        .background(.japandiOffWhite)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Button {
                                    goalDirection = .WeightLoss
                                    step = .GoalPoundsEntry
                                } label: {
                                    Text("Lose Weight")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .font(.custom("JapandiRegular", fixedSize: 18))
                                        .kerning(2)
                                        .foregroundColor(.japandiDarkGray)
                                }
                                .cornerRadius(.infinity)
                                .frame(width: 175, height: 45)
                                .buttonStyle(.borderedProminent)
                                .tint(.japandiLightGray)
                                
                                Button {
                                    goalDirection = .WeightGain
                                    step = .GoalPoundsEntry
                                } label: {
                                    Text("Gain Weight")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .font(.custom("JapandiRegular", fixedSize: 18))
                                        .kerning(2)
                                        .foregroundColor(.japandiDarkGray)
                                }
                                .cornerRadius(.infinity)
                                .frame(width: 175, height: 45)
                                .buttonStyle(.borderedProminent)
                                .tint(.japandiLightBrown)
                                
                            }
                            Spacer()
                        }
                    }
                    
                case .GoalPoundsEntry:
                    NumberEntryView(headerText: "Goal per week to  \(goalDirection == .WeightGain ? "gain" : "lose")(lbs)") { weight in
                        goalPoundsPerWeek = weight
                        upsertGoal()
                        step = .Onboarded
                    }
                    
                case .Onboarded:
                    ZStack {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                WeightChange(goalDirection: goals.first!.goalDirection, weightChange: getGoalPoundsPerWeek())
                                    .padding(.bottom, 200)
                                Spacer()
                            }
                            Spacer()
                        }
                        .background(.japandiOffWhite)
                        VStack {
                            HStack {
                                Spacer()
                                Text("Your Goal")
                                    .font(.custom("JapandiRegular", size: 25))
                                    .foregroundColor(.japandiDarkGray)
                                    .kerning(1)
                                Spacer()
                            }
                            .padding(50)
                            Spacer()
                            Button() {
                                step = .WeightEntry
                                editGoal()
                            } label: {
                                Text("Edit")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .font(.custom("JapandiRegular", fixedSize: 20))
                                    .kerning(2)
                                    .foregroundColor(.japandiDarkGray)
                            }
                            .cornerRadius(.infinity)
                            .frame(width: 150, height: 45)
                            .padding(.bottom, 200)
                            .buttonStyle(.borderedProminent)
                            .tint(.japandiLightBrown)
                            
                        }
                    }
                }
            }
            .onAppear {
                if goals.count == 1 {
                    step = .Onboarded
                }
            }
        }
    }
    
    func editGoal() -> Void {
        try? context.delete(model: Goal.self)
    }
    
    func getGoalPoundsPerWeek() -> Float {
        return goals.first!.goalPoundsPerWeek
    }
    
    
    func upsertGoal() {
        if goals.count == 1 {
            let goal = goals.first
            goal?.goalDirection = goalDirection
            goal?.goalPoundsPerWeek = goalPoundsPerWeek
            goal?.startingWeight = startingWeight
        } else {
            let goal = Goal(startingWeight, goalDirection, goalPoundsPerWeek)
            context.insert(goal)
        }
    }
}
