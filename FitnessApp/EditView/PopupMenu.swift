//
//  PopupMenu.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/27/20.
//

import SwiftUI

struct PopupMenu: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel : WorkoutModel
    var workout : Workout
    @State var possibleSuperset : [Workout]
    @Binding var superSet : [String : [Int]]
    @Binding var isNew : Bool
    @State var inSuperset = false
    @State var viewExercises = false
    @State var addExercise = false
    @State var versionNum = 0
    var body: some View {
        ZStack() {
            Color(red : 240/255, green : 240/255, blue : 240/255)
            VStack(alignment : .leading, spacing : 20) {
                Button(action : {
                    viewExercises.toggle()
                })
                {
                    HStack() {
                        Text("View Superset Exercises")
                        Spacer()
                    }
                    .font(.custom("Avenir Next Condensed", size : 24))
                    .frame(maxWidth : .infinity, maxHeight : 50)
                    .padding(.leading, 5)
                }
                if viewExercises {
                    ForEach(superSet.keys.sorted(), id : \.self) { key in
                        HStack() {
                            Text(String(superSet[key]![1]))
                                .background(Circle().fill(Color.black).frame(width: 30, height: 30))
                                .foregroundColor(Color.white)
                                .padding(.leading, 25)
                            Text(key)
                                .foregroundColor(Color.black)
                                .padding(.leading, 10)
                            Spacer()
                        }
                        .font(.custom("Avenir Next Condensed", size : 24))
                        .frame(maxWidth : .infinity, maxHeight : 50)
                    }
                }
                Button(action : {
                    addExercise.toggle()
                })
                {
                    Text("Add a Superset Exercise")
                        .padding(.leading, 5)
                }
                if addExercise {
                    ForEach(possibleSuperset) { possWorkout in
                        if possWorkout.name != workout.name {
                            buttonView(exerciseName : possWorkout.name, supersetDict : self.$superSet, viewModel : self.viewModel, versionNumber : versionNum)
                        }
                    }
                }
                Button(action : {
                    //Unlink the current exercise from the superSet array.
                    for x in superSet.keys {
                        if superSet[x]![1] > superSet[workout.name]![1] {
                            superSet[x]![1] -= 1
                        }
                    }
                    superSet[workout.name]![0] = 0
                    superSet[workout.name]![1] = 0
                    //Update here
                    if viewModel.updateSuperset(superSet) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    else {
                        print("Error")
                    }
                })
                {
                    Text("Unlink Current Exercise")
                        .foregroundColor(workout.version != 0 ? Color.black : Color.gray)
                        .padding(.leading, 5)

                }
                .allowsHitTesting(workout.version != 0)
                Spacer()
            }
            .padding(.top, 20)
            .allowsHitTesting(!isNew)
            .foregroundColor(!isNew ? Color.black : Color.gray)
            .font(.custom("Avenir Next Condensed", size : 24))
        }
        .onAppear() {
            //If this is the first exercise of the superset
            if superSet.count == 0 {
                versionNum = viewModel.latestVer()
                superSet[workout.name] = [versionNum, 1]
            }
            else {
                versionNum = workout.version
            }
        }
    }
}

struct buttonView : View {
    let exerciseName : String
    @Binding var supersetDict : [String : [Int]]
    @ObservedObject var viewModel : WorkoutModel
    var versionNumber : Int
    @State var buttonPressed = false
    @State var latestOrd = 0
    var body : some View {
        Button (action : {
            buttonPressed.toggle()
            if buttonPressed {
                //Add to supersetDict, find latest Ord + 1
                for key in supersetDict.keys {
                    if supersetDict[key]![1] > latestOrd {
                        latestOrd = supersetDict[key]![1]
                    }
                }
                supersetDict[exerciseName] = [versionNumber, latestOrd + 1]
            }
            else {
                //Need to update both in supersetDict and in the viewModel
                for x in supersetDict.keys {
                    if supersetDict[x]![1] > supersetDict[exerciseName]![1] {
                        supersetDict[x]![1] -= 1
                    }
                }
                supersetDict.removeValue(forKey : exerciseName)
            }
        })
        {
            HStack() {
                Text(" \(exerciseName) ")
                    .font(.custom("Avenir Next Condensed", size : 24))
                    .background(buttonPressed ? Color.gray.opacity(0.66) : Color(red : 240/255, green : 240/255, blue : 240/255))
                    .cornerRadius(15)
                Spacer()
            }
            .padding(.leading, 25)
        }
        .onAppear() {
            //If user closes popupmenu then reopens it need to maintain old button state
            if supersetDict.keys.contains(exerciseName) {
                buttonPressed = true
            }
        }
    }
}
