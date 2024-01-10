//
//  WeightEntry.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/31/23.
//

import Foundation
import SwiftUI
import SwiftData

struct WeightEntryView: View {
    @Environment(\.modelContext) private var context
    @State var weightInput: String = ""
    @Query private var weights: [Weight] = []
    
    var headerText: String
    var callback: (Float) -> Void
    
    
    var body: some View {
        VStack(alignment: .center) {
            Text(headerText)
                .font(.custom("JapandiRegular", size: 25))
                .kerning(2)
                .padding(30)
                .foregroundColor(.japandiLightGray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Text(weightInput)
                .font(.custom("JapandiBold", size: 75))
                .foregroundColor(.japandiDarkGray)
            
            if weightInput != "" {
                Button() {
                    onSubmit()
                } label: {
                    Text("Submit")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.custom("JapandiRegular", fixedSize: 20))
                        .kerning(2)
                        .foregroundColor(.japandiDarkGray)
                }
                .cornerRadius(.infinity)
                .frame(width: 350, height: 45)  // Adjust width and height as needed
                .buttonStyle(.borderedProminent)
                .tint(.japandiLightBrown)
            }
            //            }
            VStack {
                HStack {
                    EntryButton("1") {
                        weightInput += "1"
                    }
                    EntryButton("2") {
                        weightInput += "2"
                    }
                    EntryButton("3") {
                        weightInput += "3"
                    }
                }
                HStack {
                    EntryButton("4") {
                        weightInput += "4"
                    }
                    EntryButton("5") {
                        weightInput += "5"
                    }
                    EntryButton("6") {
                        weightInput += "6"
                    }
                }
                HStack {
                    EntryButton("7") {
                        weightInput += "7"
                    }
                    EntryButton("8") {
                        weightInput += "8"
                    }
                    EntryButton("9") {
                        weightInput += "9"
                    }
                }
                HStack {
                    EntryButton(".") {
                        if !weightInput.contains(".") && weightInput.count > 0 {
                            weightInput += "."
                        }
                    }
                    EntryButton("0") {
                        weightInput += "0"
                    }
                    
                    // Left Arrow
                    EntryButton("\u{2190}") {
                        if weightInput.count > 0 {
                            weightInput.removeLast()
                        }
                    }
                }
            }
            .frame(height: 300)
        }
        .background(.japandiOffWhite)
        .onAppear {
            
        }
    }
    
    
    func onSubmit() {
        if let weightInputFloat = Float(weightInput) {
            callback(weightInputFloat)
        }
    }
    
    func getRollingWeight() -> Float {
        let currentDate = Date.now
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        
        let recentWeights = weights.filter { $0.date >= sevenDaysAgo }
        let weightSum = recentWeights.reduce(0.0) { $0 + $1.weight }
        let rollingWeight = round((weightSum / Float(recentWeights.count) * 10) / 10)
        
        return rollingWeight
    }
    
    
    func getIsWeightLoggedToday() -> Bool {
        let calendar = Calendar.current
        if let date = weights.last?.date {
            let dayOfLastWeightLogged = calendar.component(.day, from: date)
            let currentDay = calendar.component(.day, from: Date.now)
            return dayOfLastWeightLogged == currentDay
        }
        return false
    }
    
    func seedData() {
        //        print("Seeding weights")
        context.insert(Weight(100))
        for i in 0...2 {
            let weight = Weight(Float(Int.random(in: 126..<130)))
            weight.date = Calendar.current.date(byAdding: .day, value: i, to: weight.date)!
            context.insert(weight)
        }
        
    }
}

