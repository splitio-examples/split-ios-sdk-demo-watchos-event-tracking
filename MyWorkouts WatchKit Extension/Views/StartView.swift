/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The start view.
*/

import SwiftUI
import HealthKit

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var split: SplitWrapper
    
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]

    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(
                workoutType.name,
                destination: SessionPagingView().onAppear() {

                    if "on" == split.eval("track_workouts") {           // We can toggle tracking on or off using this feature flag (split) in the Split Management Console (ensure the Environment setting matches the client API key set in SplitWrapper).
                        
                        _ = split.track("\(workoutType.name)_workout")  // Sends an event to Split cloud, where we can set up a metric to count the number of times each workout type is selected.
                        _ = split.track("some_workout")                 // The count of this event can be the denominator for a ratio metric, allowing us to see the workout selection as a ratio over all workout selections.
                        
                        split.flush()   // For testing purposes, we can choose to immediately send data to Split cloud.
                    }
                    
                    // If Split's timeout event fired, split.eval("track_workouts") would return "CONTROL", so no tracking would happen.
                },
                tag: workoutType,
                selection: $workoutManager.selectedWorkout)
            .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationBarTitle("Workouts")
        .onAppear {
            workoutManager.requestAuthorization()
        }
        .disabled(!split.isReady && !split.isReadyTimedOut)
        .overlay(loadingOverlay)
    }

    @ViewBuilder private var loadingOverlay: some View {
        if !split.isReady && !split.isReadyTimedOut {
            ProgressView()
        
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(WorkoutManager())
            .environmentObject(SplitWrapper.instance)
    }
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Bike"
        case .walking:
            return "Walk"
        default:
            return ""
        }
    }
}
