import SwiftUI
import SwiftData
import HealthKit

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    @State private var isWeightLoggedToday: Bool = false
    @Query private var weights: [Weight] = []
    @Environment(\.scenePhase) private var scenePhase
    private let healthKitManager = HealthKitManager()
    
    init() {
//        healthKitManager.startObservingWeightChanges()
//        healthKitManager.fetchAllHealthData { weight in
//            if let weight = weight {
//                print("Weight today: \(weight) kilograms")
//            } else {
//                print("No weight data available for today.")
//            }
//        }
    }
    
    var body: some View {
        VStack {
           if true {
                TabView {
                    VStack {
                        WeekView()
                    }
                    .tabItem {
                        Image(systemName: "dumbbell.fill")
                    }
                    VStack {
                        WeightChartView()
                    }.tabItem {
                        Image(systemName: "chart.bar.fill").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }
            } else {
                WeightEntry(weightLoggedBinding: $isWeightLoggedToday)
            }
        }
        .onAppear {
            isWeightLoggedToday = getIsWeightLoggedToday(weights)
        }
        .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
            isWeightLoggedToday = getIsWeightLoggedToday(weights)
        }
    
}

func clearWeights() -> Void {
    try? context.delete(model: Weight.self)
}
}



func getIsWeightLoggedToday(_ weights: [Weight]) -> Bool {
    let _isWeightLoggedToday: Bool
    if let lastWeight = weights.last?.date {
        _isWeightLoggedToday = Calendar.current.isDateInToday(lastWeight)
    } else {
        _isWeightLoggedToday = false
    }
    return _isWeightLoggedToday
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: Weight.self, inMemory: true)
    }
}
