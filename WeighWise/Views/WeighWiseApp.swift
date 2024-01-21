//
//  WeighWiseTestApp.swift
//  WeighWiseTest
//
//  Created by 625098 on 12/24/23.
//

import SwiftUI
import SwiftData

@main
struct WeighWiseApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DateEntry.self, Goal.self])
    }
}
