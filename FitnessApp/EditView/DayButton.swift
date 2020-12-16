//
//  DayButton.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/4/20.
//

import SwiftUI

struct DayButton: View {
    var dayChosen : String
    @Binding var editButton : Bool
    @ObservedObject var viewModel = WorkoutModel()
    @State var selectedElement = Workout()
    let circleColors : [Color] = [Color.white, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink, Color.black, Color.gray]
    var body: some View {
        VStack() {
            ScrollView(.vertical) {
                ForEach(viewModel.workouts) { workout in
                    HStack() {
                        if editButton {
                            Button(action : {
                                withAnimation { () -> () in
                                    self.viewModel.workouts.removeAll { $0.id == workout.id}
                                }
                                viewModel.deleteExercise(name: workout.name)
                            })
                            {
                                Image(systemName : "minus.circle.fill")
                                    .foregroundColor(Color.red)
                                    .padding()
                                    .frame(width : 40, height : 40)
                            }
                        }
                        VStack(spacing : 0) {
                            NavigationLink(destination : EditView(model : workout, viewModel : viewModel)) {
                                HStack() {
                                    if workout.version > 0 {
                                        Circle().fill(circleColors[workout.version]).shadow(radius : 1)
                                            .frame(width : 20, height : 20)
                                            .padding()
                                    }
                                    else {
                                        Circle().fill(Color.white).shadow(radius : 1)
                                            .frame(width : 20, height : 20)
                                            .padding()
                                    }
                                    Text(workout.name)
                                        .font(.custom("Comic Sans MS", size : 24))
                                        .foregroundColor(editButton ? Color.gray : Color.black)
                                    Spacer()
                                }
                            }
                            .allowsHitTesting(!editButton)
                        }
                        .frame(maxWidth : .infinity, minHeight : 75)
                        .transition(AnyTransition.scale)
                        .background(Color.white.shadow(color: Color/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 1, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/))
                        .cornerRadius(15)
                        .animation(.spring(), value : viewModel.workouts)
                        .onTapGesture {
                            withAnimation(.spring()) { self.selectedElement = workout }
                        }
                        
                    }
                    .padding(.bottom, 10)
                }
            }
            .padding()
            HStack() {
                NavigationLink(destination : EditView(model : Workout(), viewModel : viewModel))
                {
                    HStack() {
                        Spacer()
                        Image(systemName: "plus.circle")
                        Text("Add a Exercise")
                        Spacer()
                    }
                    .font(.custom("Comic Sans MS", size : 24))
                    .frame(maxWidth : .infinity, maxHeight : 50)
                    .foregroundColor(Color.orange)
                    .background(Color.black)
                    .cornerRadius(20)
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear() {
            viewModel.changeDay(day: dayChosen)
            viewModel.fetchData()
        }
        .navigationBarItems(trailing :
            Button(action : {
                editButton.toggle()
            }) { Text(editButton ? "Done" : "Edit") }
        )
    }
}

