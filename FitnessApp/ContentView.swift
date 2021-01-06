//
//  ContentView.swift
//  FitnessApp
//
//  Created by Kelley Wu on 10/30/20.
//

import SwiftUI
import Firebase
struct ContentView: View {
    @ObservedObject var viewModel = WorkoutModel()
    var body: some View {
        TabView {
            NavigationView {
                workoutSelection(viewModel : self.viewModel)
            }
                .tabItem {
                    Image(systemName : "heart")
                    Text("Start Workout")
                }
            NavigationView {
                EditWorkout()
            }
                .tabItem {
                    Image(systemName : "square.and.pencil")
                    Text("Edit Workout")
                }
            InputView()
            .tabItem {
                Text("Progress Report")
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    @ObservedObject var viewModel = WorkoutModel()
//    static var previews: some View {
//        ContentView(viewModel : viewModel)
//    }
//}
