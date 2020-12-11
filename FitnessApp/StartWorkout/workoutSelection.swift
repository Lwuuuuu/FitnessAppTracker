//
//  BeginWorkout.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/14/20.
//
// Check if current and prev are the same
// Update the previous workout with the new one if manually picked
//
import SwiftUI

struct workoutPreview : View {
    var workoutList : [Workout]
    var completedExercises : [String]
    @State var isValid = false
    var body : some View {
        ZStack {
            VStack(spacing : 0) {
                ForEach(workoutList, id : \.self) { workout in
                    HStack() {
                        Spacer()
                        Text(workout.name + "  ->  " + String(workout.reps.count))
                            .foregroundColor(.white)
                            .font(.custom("Avenir Next Condensed", size : 24))
                        Spacer()
                    }
                }
            }
            .background(Color(red: 55.25/255, green: 62.9/255, blue: 64.6/255))
            .cornerRadius(30)
            if isValid {
                Color.gray
                    .opacity(0.9)
                    .cornerRadius(30)
                VStack() {
                    Spacer()
                    Image(systemName : "checkmark.circle")
                        .foregroundColor(Color.green)
                        .font(.system(size : 30))
                    Spacer()
                }
            }
        }
        .onAppear() {
            isValid = didExercise()
        }
    }
    func didExercise() -> Bool {
        for workout in workoutList {
            if completedExercises.contains(workout.name) {
                return true
            }
        }
        return false
    }
}


struct workoutSelection: View {
    @ObservedObject var viewModel : WorkoutModel
    var body: some View {
        VStack(spacing : 3) {
            HStack() {
                Text(getTodayWeekDay())
                    .foregroundColor(Color.orange)
                    .font(.custom("Avenir Next Condensed", size : 48))
                    .padding(.leading, 5)
                Spacer()
            }
            Rectangle()
                .fill(Color.gray)
                .frame(maxWidth : .infinity, maxHeight: 2)
                .edgesIgnoringSafeArea(.horizontal)
            ScrollView(.vertical) {
                VStack(spacing : 20) {
                    ForEach(viewModel.orderedExercises(), id : \.self) { element in
                        NavigationLink(destination : beginWorkout(timeRemaining: 120, setNum: 1, workouts: element, model: viewModel))
                        {
                            workoutPreview(workoutList : element, completedExercises : self.viewModel.completedWorkouts)
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
        .navigationBarHidden(true)
        .navigationBarTitle(Text("Home"))
        .background(
            Image("rilakkuma")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear() {
            self.viewModel.changeDay(day: getTodayWeekDay())
            self.viewModel.fetchData()
        }
    }
    func getTodayWeekDay() -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EEEE"
           let weekDay = dateFormatter.string(from: Date())
           return weekDay
     }
}


//struct workoutSelection_Previews: PreviewProvider {
//    static var previews: some View {
//        workoutSelection()
//    }
//}
