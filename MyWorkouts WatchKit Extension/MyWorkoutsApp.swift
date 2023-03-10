/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The entry point into the app.
*/

import SwiftUI

@main
struct MyWorkoutsApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var split = SplitWrapper.instance

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
            .environmentObject(split)
        }
    }
}
