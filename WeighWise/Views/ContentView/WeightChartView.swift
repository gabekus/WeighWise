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

struct WeightChartView: View {
    @Environment(\.modelContext) private var context
    @Query private var weights: [Weight]
    
    var body: some View {
        List {
            let groupedByMonth = weights.reduce(into: [String: [Weight]]()) { result, weight in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM"
                let fullMonth = dateFormatter.string(from: weight.date)
                result[fullMonth, default: []].append(weight)
            }
            
            ForEach(groupedByMonth.sorted(by: { $0.key > $1.key }), id: \.key) { (month, monthlyWeights) in
                Section(header: Text("\(month)")) {
                    ForEach(monthlyWeights, id: \.date) { weight in
                        HStack {
                            Text("\(Calendar.current.component(.day, from: weight.date))")
                            Text("\(formatWeight(weight.weight)) lbs")
                        }
                    }
                }
            }
        }
//        Chart(weights.sorted { $0.date < $1.date }) {
//            LineMark(
//                x: .value("Month", $0.date),
//                y: .value("Weight", $0.weight )
//            ).foregroundStyle(Color("JapandiLightGray"))
//        }
//        .aspectRatio(2, contentMode: .fit)
//        .onAppear() {
//            seedData()
//        }
    }
    
    func seedData() {
//        context.insert(Weight(100))
        for i in 0...10 {
            let weight = Weight(Float(Int.random(in: 138..<143)))
            weight.date = Calendar.current.date(byAdding: .day, value: i, to: weight.date)!
//            context.insert(weight)
        }
        
    }
}


#Preview {
    WeightChartView()
        .modelContainer(for: Weight.self, inMemory: true)
}
