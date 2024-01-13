import SwiftUI
import SwiftData
import HealthKit
import ConfettiSwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var isWeightLoggedToday = false
    @State private var selectedTab = 0
    @Query private var weights: [Weight] = []
    @State private var counter = 0
    @Environment(\.scenePhase) private var scenePhase
    
    private let healthKitManager = HealthKitManager()
    
    var body: some View {
        ZStack {
            VStack {
                if isWeightLoggedToday {
                    TabView(selection: $selectedTab) {
                        WeightCalendar().tabItem { Image(systemName: "chart.bar.fill") }.tag(0)
                        WeekView().tabItem { Image(systemName: "dumbbell.fill") }.tag(1)
                            .scaleEffect(selectedTab == 2 ? 1.5 : 1.0)

                        OnboardingView().tabItem { Image(systemName: "hand.tap") }.tag(2)
                    }
                } else {
                    WeightEntryView(headerText: "Enter Weight") { weight in
                        isWeightLoggedToday = true
                        addWeight(weight)
                        if isTodaySaturday() && fullWeekLogged() {
                            counter += 1
                        }
                    }
                }
            }
            .background(.japandiOffWhite)
            
            .onAppear { isWeightLoggedToday = getIsWeightLoggedToday(weights) }
            .onChange(of: scenePhase) { _, _ in isWeightLoggedToday = getIsWeightLoggedToday(weights) }
            EmptyView().confettiCannon(counter: $counter, colors: [.japandiGreen, .japandiRed, .japandiYellow, .japandiMintGreen])
        }
    }
    
    func isTodaySaturday() -> Bool {
        return Calendar.current.component(.weekday, from: Date()) == 7
    }
    
    func fullWeekLogged() -> Bool {
        if let currentWeeksWeights = try? getCurrentWeeksWeights(weights) {
            return currentWeeksWeights.filter { $0.weight != NONEXISTENT_WEIGHT }.count == 7
        } else {
            return false
        }
    }
    
    func addWeight(_ weight: Float) {
        let newWeight = Weight(weight)
        context.insert(newWeight)
    }
    
    func isSunday() -> Bool {
        return Calendar.current.component(.weekday, from: Date()) == 7
    }
    
    func clearWeights() {
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

let formatWeight = { (_ flt: Float) -> String in String(format: "%.1f", flt)}

func getSunday(for date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.weekday], from: date)
    
    if let weekday = components.weekday {
        let daysToSunday = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -daysToSunday, to: date) ?? date
    }
    
    return date
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().modelContainer(for: [Weight.self, Goal.self], inMemory: true)
    }
}
