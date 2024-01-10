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
        VStack {
            switch(step) {
            case .WeightEntry:
                WeightEntryView(headerText: "Enter current weight") { weight in
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
                            .frame(width: 175, height: 45)  // Adjust width and height as needed
                            .buttonStyle(.borderedProminent)
                            .tint(.japandiLightBrown)
                            
                        }
                        Spacer()
                    }
                }
                
            case .GoalPoundsEntry:
                WeightEntryView(headerText: "Goal per week to  \(goalDirection == .WeightGain ? "gain" : "lose")(lbs)") { weight in
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
                            Image(systemName: "arrow.\(goals.first!.goalDirection == .WeightGain ? "up" : "down")").font(.custom("", size: 20))
                            Text(getGoalPoundsPerWeek()) + Text(" lbs").font(.custom("JapandiRegular", size: 20))
                                .kerning(1)
                            Spacer()
                        }
                        .font(.custom("JapandiRegular", size: 75))
                        .foregroundColor(.japandiDarkGray)
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
    
    func getGoalPoundsPerWeek() -> String {
        return formatWeight(goals.first!.goalPoundsPerWeek)
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
