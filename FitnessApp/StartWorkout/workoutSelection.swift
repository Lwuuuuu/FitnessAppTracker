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
    @State var numSets = 0
    var body : some View {
        ZStack {
            VStack(spacing : 0) {
                ForEach(workoutList, id : \.self) { workout in
                    HStack() {
                        Spacer()
                        Text(workout.name)
                            .foregroundColor(Color.black)
                            .font(.custom("Avenir Next Condensed", size : 24))
                        Spacer()
                    }
                }
                Rectangle()
                    .fill(Color.gray)
                    .frame(width : 200, height: 1)
                    .edgesIgnoringSafeArea(.horizontal)
                HStack() {
                    Image(systemName : "info.circle")
                    Text("Total number of Sets : " + String(self.numSets))
                }
                .foregroundColor(Color.black)
                .font(.custom("Avenir Next Condensed", size : 16))
            }
            .background(Color.white.shadow(color: Color/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 1, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/))
            .cornerRadius(15)
            if isValid {
                Color.gray
                    .opacity(0.9)
                    .cornerRadius(15)
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
            numSets = calcSets()
        }
    }
    func calcSets() -> Int {
        var ans = 0
        for workout in workoutList {
            ans += workout.reps.count
        }
        return ans
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
        ZStack {
            Color(red : 240/255, green : 240/255, blue : 240/255)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack(spacing : 3) {
                DropDownMenu(viewModel: viewModel, currentDay: getTodayWeekDay())
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxWidth : .infinity, maxHeight: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                ScrollView(.vertical) {
                    VStack(spacing : 20) {
                        ForEach(viewModel.orderedExercises(), id : \.self) { element in
                            if let leftoverName = inLeftover(exerciseSet : element) {
                                NavigationLink(destination : beginWorkout(timeRemaining: viewModel.restTime(exerciseList: element, curSet: self.viewModel.leftoverWorkouts[leftoverName]!), setNum: self.viewModel.leftoverWorkouts[leftoverName]!, workouts: element, model : viewModel))
                                {
                                    workoutPreview(workoutList : element, completedExercises : self.viewModel.completedWorkouts)
                                }
                            }
                            else {
                                NavigationLink(destination : beginWorkout(timeRemaining: viewModel.restTime(exerciseList: element, curSet: 1), setNum: 1, workouts: element, model : viewModel))
                                {
                                    workoutPreview(workoutList : element, completedExercises : self.viewModel.completedWorkouts)
                                }
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .navigationBarHidden(true)
            .navigationBarTitle(Text("Home"))
        }
        .onAppear() {
//            self.viewModel.changeDay(day: getTodayWeekDay())
//            self.viewModel.fetchData()
        }
    }
    func getTodayWeekDay() -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EEEE"
           let weekDay = dateFormatter.string(from: Date())
           return weekDay
     }
    func inLeftover(exerciseSet : [Workout]) -> String? {
        for exercise in exerciseSet {
            if self.viewModel.leftoverWorkouts.keys.contains(exercise.name) {
                return exercise.name
            }
        }
        return nil
    }
}


struct DropDownMenu : View {
    let daysofWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @ObservedObject var viewModel : WorkoutModel
    @State var currentDay : String
    @State var expand = false
    var body : some View {
        VStack {
            HStack {
                Button(action : {
                    withAnimation {
                        self.expand.toggle()
                    }
                })
                {
                    HStack() {
                        Text(currentDay)
                            .padding(.leading, 5)
                    }
                }
                Spacer()
                Text(self.numSets() + " Sets")
            }
            .foregroundColor(Color.black)
            .font(.custom("Avenir Next Condensed", size : 48))
            ForEach(daysofWeek, id : \.self) { day in
                if day != currentDay && expand {
                    Button(action : {
                        withAnimation {
                            self.currentDay = day
                            self.viewModel.changeDay(day: day)
                            self.viewModel.fetchData()
                            self.expand.toggle()
                        }
                    })
                    {
                        HStack {
                            Text(day)
                                .foregroundColor(Color.black)
                                .font(.custom("Avenir Next Condensed", size : 48))
                                .padding(.leading, 5)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    func numSets() -> String {
        var ans = 0
        for workout in viewModel.workouts {
            ans += workout.reps.count
        }
        return String(ans)
    }
}
