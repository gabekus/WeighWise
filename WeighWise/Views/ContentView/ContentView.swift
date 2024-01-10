import SwiftUI
import SwiftData
import HealthKit
import ConfettiSwiftUI

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    @State private var isWeightLoggedToday: Bool = false
    @State private var selectedTab: Int = 1
    @Query private var weights: [Weight] = []
    @State private var counter: Int = 0
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
        ZStack {
            VStack {
                if isWeightLoggedToday {
                    TabView(selection: $selectedTab) {
                        VStack {
                            WeightChartView()
                        }.tabItem {
                            Image(systemName: "chart.bar.fill")
                        }.tag(0)
                        VStack {
                            WeekView()
                        }.tag(1)
                            .tabItem {
                                Image(systemName: "dumbbell.fill")
                            }
                        VStack {
                            OnboardingView()
                        }.tag(2)
                            .tabItem {
                                Image(systemName: "hand.tap")
                            }
                    }
                } else {
                    WeightEntryView(headerText: "Enter Weight") { weight in
                        isWeightLoggedToday = true
                        addWeight(weight)
                        //                    if Calendar.current.component(.weekday, from: Date()) == 7 {
                        counter += 1
                        //                    }
                    }
                }
                
                
            }
            
            .onAppear {
                isWeightLoggedToday = getIsWeightLoggedToday(weights)
            }
            .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
                isWeightLoggedToday = getIsWeightLoggedToday(weights)
            }
            EmptyView()
                .confettiCannon(counter: $counter, colors: [.japandiGreen, .japandiRed, .japandiYellow, .japandiMintGreen])
        }
    }
    
    func addWeight(_ weight: Float) {
        let newWeight = Weight(weight)
        context.insert(newWeight)
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
            .modelContainer(for: [Weight.self, Goal.self], inMemory: true)
    }
}
