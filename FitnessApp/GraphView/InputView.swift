//
//  InputView.swift
//  FitnessApp
//
//  Created by Kelley Wu on 12/16/20.
//

import SwiftUI
import FirebaseFirestore

struct InputView: View {
    @State var data = [String]()
    @State var weightRange = ["0", "0"]
    @State var repRange = ["0", "0"]
    @State private var chosenExercise = ""
    @State private var presentPicker = false
    @State private var calculatePressed = false
    var body: some View {
        ZStack {
            Color(red: 240/255, green: 240/255, blue: 240/255)
                .ignoresSafeArea(.all)
            VStack {
                HStack() {
                    Spacer()
                    TextField("Select Exercise", text : $chosenExercise).disabled(true)
                        .background(Color(red: 245/255, green: 245/255, blue: 245/255).shadow(color: Color/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 1))
                        .cornerRadius(15)
                        .font(.custom("Comic Sans MS", size : 36))
                        .frame(maxWidth : .infinity)
                        .multilineTextAlignment(.center)
                        .overlay (
                            Button(action : {
                                withAnimation {
                                    presentPicker = true
                                }
                            })
                            {
                                RoundedRectangle(cornerRadius : 15).foregroundColor((Color.clear))
                            }
                        )
                        .padding()
                    Spacer()
                }
                VStack(spacing : 0) {
                    Text("Weight (Optional)")
                        .foregroundColor(Color.black)
                    RangeView(rangeNumbers: $weightRange)
                }
                VStack(spacing : 0) {
                    Text("Reps (Optional)")
                        .foregroundColor(Color.black)
                    RangeView(rangeNumbers: $repRange)
                }
                Button(action : {
                    calculatePressed = true
                })
                {
                    Text("Calculate")
                        .frame(width : 200)
                        .foregroundColor(Color.black)
                        .font(.custom("Comic Sans MS", size : 30))
                        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
                        .overlay(RoundedRectangle(cornerRadius : 15).stroke(Color.black, lineWidth : 1))
                        .padding()
                }
                .sheet(isPresented : $calculatePressed) {
                    LineGraph(name : chosenExercise, weights : weightRange, reps : repRange)
                }
                Spacer()
            }
            if presentPicker {
                CustomPickerView(items : data, pickerField : $chosenExercise, presentPicker: $presentPicker)
            }
        }
        .onAppear() {
            self.getExercises() { res in
                self.data = res
            }
        }
    }
    func getExercises(completion : @escaping(([String]) -> ())) {
        var ans = [String]()
        let db = Firestore.firestore()
        let g = DispatchGroup()
        g.enter()
        db.collection("users/user1/workoutData").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting docs : \(err)")
                g.leave()
            }
            else {
                for document in QuerySnapshot!.documents {
                    ans.append(document.documentID)
                }
                g.leave()
            }
        }
        g.notify(queue: .main) {
            completion(ans)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}


