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
    let defaults = UserDefaults.standard
    let prevExercise = UserDefaults.standard.string(forKey : "name")
    var body: some View {
        if prevExercise != "None" && prevExercise != nil{
            let setNumber = defaults.integer(forKey: "set")
            if let exerciseSet = self.viewModel.findExerciseSet(exerciseName: prevExercise!) {
                beginWorkout(timeRemaining: viewModel.restTime(exerciseList: exerciseSet, curSet: setNumber), setNum: setNumber, workouts : exerciseSet, model : viewModel)
            }
            else {
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
                        Image(systemName : "chart.bar")
                        Text("Progress Report")
                    }
                }
            }
        }
        else {
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
                    Image(systemName : "chart.bar")
                    Text("Progress Report")
                }
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

