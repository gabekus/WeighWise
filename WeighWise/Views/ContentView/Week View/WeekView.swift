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
    @Query private var weights: [Weight] = [Weight(5)]
    @State private var currentWeeksWeights: [Weight] = []
    @Environment(\.scenePhase) private var scenePhase
    @State private var weekAverage: Float = 0
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if !currentWeeksWeights.isEmpty {
                        ForEach(1...7, id: \.self) { i in
                            DayBubble(dayOfWeek: i, weight: currentWeeksWeights.indices.contains(i - 1) ? currentWeeksWeights[i - 1] : Weight(NONEXISTENT_WEIGHT))
                            
                        }
                    }
                    Spacer()
                }.onAppear {
                    do {
                        var currentWeeksWeightsResult = try getCurrentWeeksWeights(weights)
                        currentWeeksWeights = []
                        for i in 1...7 {
                            if currentWeeksWeightsResult.contains(where: { i ==  Calendar.current.component(.weekday, from: $0.date)}) {
                                currentWeeksWeights.append(currentWeeksWeightsResult.removeFirst())
                            } else {
                                currentWeeksWeights.append(Weight(NONEXISTENT_WEIGHT))
                            }
                        }
                        weekAverage = calculateAverage(of: currentWeeksWeights)
                    } catch {
                        print("Error \(error)")
                    }
                }
                .onChange(of: scenePhase) {
                    do {
                        var currentWeeksWeightsResult = try getCurrentWeeksWeights(weights)
                        currentWeeksWeights = []
                        for i in 1...7 {
                            if currentWeeksWeightsResult.contains(where: { i ==  Calendar.current.component(.weekday, from: $0.date)}) {
                                currentWeeksWeights.append(currentWeeksWeightsResult.removeFirst())
                            } else {
                                currentWeeksWeights.append(Weight(NONEXISTENT_WEIGHT))
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
                Text("\(formatWeight(weekAverage))").font(.custom("JapandiBold", size: 85)).padding(10)
                    .foregroundColor(.japandiDarkGray)
                Spacer()
            }
            
        }
    }
}

func calculateAverage(of array: [Weight]) -> Float {
    let nonNilWeights = array.compactMap { $0.weight > 0 ? $0.weight : nil }
    let average = nonNilWeights.isEmpty ? nil : nonNilWeights.reduce(0, +) / Float(nonNilWeights.count)
    
    return average ?? 0
}

func getCurrentWeeksWeights(_ weights: [Weight]) throws -> [Weight] {
    return weights.filter { $0.date >= getSunday(for: Date()) }
}


#Preview {
    WeekView()
        .modelContainer(for: Weight.self, inMemory: true)
}
