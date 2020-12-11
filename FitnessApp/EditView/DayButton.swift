//
//  DayButton.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/4/20.
//

import SwiftUI

struct DayButton: View {
    @State var buttonPressed = false
    var dayChosen : String
    @Binding var editButton : Bool
    @ObservedObject var viewModel = WorkoutModel()
    @State var selectedElement = Workout()
    var body: some View {
        VStack() {
//            VStack(spacing : 0) {
//                Button(action : {
//                    buttonPressed.toggle()
//                }) {
//                    HStack() {
//                        Text(dayChosen)
//                        Spacer()
//                        Image(systemName : buttonPressed ? "chevron.down" : "chevron.right").padding(.trailing, 10)
//                    }
//                    .foregroundColor(Color.black)
//                    .font(.custom("Avenir Next Condensed", size : 42))
//                    .multilineTextAlignment(.leading)
//                    .padding(.leading, 5)
//
//                }
//                .buttonStyle(DayButtonStyle())
//                Rectangle()
//                    .fill(Color.orange)
//                    .frame(maxWidth : .infinity, maxHeight: 2)
//                    .edgesIgnoringSafeArea(.horizontal)
            }
            if buttonPressed {
                    VStack(alignment: .leading) {
                        if viewModel.workouts.count > 0 {
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
                                                .padding(.leading, 25)
                                        }
                                    }
                                    //Currently exisiting exercise
                                    NavigationLink(destination : EditView(model : workout, viewModel : viewModel))
                                    {
                                        Text(workout.name)
                                            .font(.custom("Comic Sans MS", size : 24))
                                            .foregroundColor(editButton ? Color.gray : Color.black)
                                            .padding(.leading, 30)
                                            .padding(.trailing, editButton ? 50 : 0)
                                        Spacer()
                                    }
                                    .allowsHitTesting(!editButton)
                                }
                                .frame(maxWidth : .infinity, maxHeight : 50)
                                .transition(AnyTransition.scale)
                                .animation(.spring(), value : viewModel.workouts)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        self.selectedElement = workout
                                    }
                                }
                            }
                        }
                        //New exercise
                        NavigationLink(destination : EditView(model : Workout(), viewModel : viewModel))
                        {
                            HStack() {
                                Spacer()
                                Image(systemName: "plus.circle")
                                Text("Add a Exercise")
                                Spacer()
                            }
                            .font(.custom("Avenir Next Condensed", size : 24))
                            .frame(maxWidth : .infinity, maxHeight : 50)
                            .foregroundColor(Color.orange)
                        }
                    }
                    .background(Color.white.shadow(color: Color/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 1, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/))
//                    .background(Color(red : 65/255, green : 74/255, blue : 76/255))
            }
        }
        .padding()
        .onAppear() {
            viewModel.changeDay(day: dayChosen)
            viewModel.fetchData()
        }
        .navigationBarItems(trailing :
            Button(action : {
                editButton.toggle()
            })
            {
                if editButton {
                    Text("Done")
                }
                else {
                    Text("Edit")
                }
            }
        )
    }
}


//struct DayButtonStyle: ButtonStyle {
//    func makeBody(configuration: Self.Configuration) -> some View {
//        configuration.label
//            .frame(maxWidth: .infinity, maxHeight : 50)
//            .background(Color.white.shadow(color : Color.black, radius : 1, x: 0, y: 0))
////            .background(configuration.isPressed ? Color.black.opacity(0.5) : Color.white.shadow(color : Color.black, radius : 1, x: 0, y: 0))
//            .foregroundColor(Color.white)
//    }
//}


//struct LabelledDivider: View {
//
//    let label: String
//    let horizontalPadding: CGFloat
//    let color: Color
//
//    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .black) {
//        self.label = label
//        self.horizontalPadding = horizontalPadding
//        self.color = color
//    }
//
//    var body: some View {
//        VStack(spacing : 0) {
//            Text(label).foregroundColor(color)
//                .font(.custom("Avenir Next Condensed", size : 36))
//                .multilineTextAlignment(.leading)
//            Rectangle()
//                .fill(Color.orange)
//                .frame(maxWidth : .infinity, maxHeight: 2)
//                .edgesIgnoringSafeArea(.horizontal)
//        }
//        .padding(.trailing, 5)
//    }
//}


//struct DayButton_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}
