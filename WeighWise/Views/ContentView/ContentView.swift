import SwiftUI
import SwiftData
import HealthKit
import ConfettiSwiftUI

enum EntryStep {
    case WeightEntry
    case CalorieEntry
    case WeightAndCaloriesEnteredToday
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var entryStep: EntryStep = .WeightEntry
    @State private var selectedTab = 1
    @Query private var dateEntries: [DateEntry] = []
    @State private var showWeekSummary = false
    @Environment(\.scenePhase) private var scenePhase
    
    private let healthKitManager = HealthKitManager()
    
    var body: some View {
        ZStack {
            VStack {
                if entryStep == .WeightAndCaloriesEnteredToday {
                    if showWeekSummary {
                        WeekSummaryView {
                            showWeekSummary = false
                            selectedTab = 0
                        }
                    } else {
                        TabView(selection: $selectedTab) {
                            WeightCalendar().tabItem { Image(systemName: "chart.bar.fill") }.tag(0)
                            WeekView().tabItem { Image(systemName: "dumbbell.fill") }.tag(1)
                                .tabItem { Image(systemName: "dumbbell.fill") }.tag(1)
                            OnboardingView().tabItem { Image(systemName: "hand.tap") }.tag(2)
                        }
                    }
                } else if entryStep == .WeightEntry {
                    NumberEntryView<Float>(headerText: "Enter Weight") { weight in handleWeightEntered(weight) }
                } else {
                    NumberEntryView<Int>(headerText: "Enter Yesterday's Calories") { calories in handleCaloriesEntered(calories) }
                }
            }
            .background(.japandiOffWhite)
            .onAppear {
#if DEBUG
                //                guard !dateEntries.isEmpty else {
                //                    return
                //                }
//                                                clearWeights()
//                                                seedData()
#endif
                entryStep = getEntryStep()
            }
            .onChange(of: scenePhase) { _, _ in entryStep = getEntryStep() }
        }
    }
    
    func handleWeightEntered(_ weight: Float) {
        entryStep = .CalorieEntry
        addDateEntry(weight, nil)
    }
    
    func handleCaloriesEntered(_ calories: Int) {
        entryStep = .WeightAndCaloriesEnteredToday
        let todaysWeight = dateEntries.last!.weight
        addDateEntry(todaysWeight, calories)
        if isTodaySaturday() && fullWeekLogged() {
            showWeekSummary = true
        }

    }
    
    func seedData() {
        #if DEBUG
        print("Seeding weights")
//        let dateEntry = DateEntry(100, 1500)
//        weight.date = Calendar.current.date(byAdding: .day, value: , to: weight.date)!
//        context.insert(dateEntry)
                for i in 1...30 {
                    let dateEntry = DateEntry(Float(Int.random(in: 135..<145)), Int.random(in: 2500...3000))
                    dateEntry.date = Calendar.current.date(byAdding: .day, value: -i, to: dateEntry.date)!
                    context.insert(dateEntry)
                }
        #endif
    }
    
    func isTodaySaturday() -> Bool {
        return Calendar.current.component(.weekday, from: Date()) == 7
    }
    
    func fullWeekLogged() -> Bool {
        if let currentWeeksWeights = try? getCurrentWeeksWeights(dateEntries) {
            return currentWeeksWeights.filter { $0.weight != NONEXISTENT_WEIGHT }.count == 7
        } else {
            return false
        }
    }
    
    func addDateEntry(_ weight: Float, _ calories: Int?) {
        let calendar = Calendar.current
        
        if let lastDate = dateEntries.last?.date {
            let todaysWeightExists = calendar.startOfDay(for: lastDate) == calendar.startOfDay(for: Date())
            
            if todaysWeightExists {
                dateEntries.last!.calories = calories
            } else {
                let newWeight = DateEntry(weight, calories)
                context.insert(newWeight)
            }
        } else {
            let newWeight = DateEntry(weight, calories)
            context.insert(newWeight)
        }
    }
    
    
    func isSunday() -> Bool {
        return Calendar.current.component(.weekday, from: Date()) == 7
    }
    
    func clearWeights() {
        #if DEBUG
        try? context.delete(model: DateEntry.self)
        #endif
    }
    
    func getEntryStep() -> EntryStep {
        if let lastDateEntry = dateEntries.last {
            let dateEntryExists = Calendar.current.isDateInToday(lastDateEntry.date)
            if dateEntryExists {
                if lastDateEntry.calories == nil {
                    return .CalorieEntry
                } else {
                    return .WeightAndCaloriesEnteredToday
                }
            }
        } else {
            return .WeightEntry
        }
        return .WeightEntry
    }
    
    let formatFloat = { (_ flt: Float) -> String in String(format: "%.1f", flt)}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().modelContainer(for: [DateEntry.self, Goal.self], inMemory: true)
    }
}
