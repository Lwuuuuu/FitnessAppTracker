//
//  test1.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/4/20.
//

import SwiftUI

struct test1: View {
    @ObservedObject private var viewModel = WorkoutModel()
    var body: some View {
        NavigationView {
            List(viewModel.workouts) { workout in
                VStack() {
                    Text(workout.name)
//                    Text(workout.weight)
//                    Text(workout.reps)
//                    Text(workout.sets)
                }
            }
        } .onAppear() {
            self.viewModel.fetchData()
        }
    }
}

struct test1_Previews: PreviewProvider {
    static var previews: some View {
        test1()
    }
}
