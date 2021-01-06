//
//  beginWorkout.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/19/20.
//

import SwiftUI
import UIKit
import Combine
import FirebaseFirestore
struct beginWorkout: View {
    @State var weights = Array(repeating : "", count : 30)
    @State var reps = Array(repeating : "", count : 30)
    @State var prevWorkout = Dictionary<String, [String]>()
    //(Confirm Button) Controls when view moves to the next exercise
    @State var nextExercise = false
    // (Controls all buttons in the view) Toggles background color and AllowsHitTest. When false bottom menu greyed out, when true top menu is greyed out
    @State var startRest = false
    // If the two text fields are not filled out leave an error message
    @State var missingExercise = false
    // (Skip Rest Button) Controls when user wants to move to next exercise
    @State var skipRest = false
    // The timer for the rest period has begun
    @State var startTimer = false
    // Confirm button will be tappable and blue background when both startTimer and timerFinished are true
    @State var timerFinished = false
    @State private var isActive = true
    @State var leaveApp = NSDate().timeIntervalSince1970
    @State var timeRemaining : Int
    let timer = Timer.publish(every : 1, on : .main, in : .common).autoconnect()
    var setNum : Int
    var workouts : [Workout]
    @ObservedObject var model : WorkoutModel
    var body: some View {
        ScrollView(.vertical) {
            VStack() {
                HStack() {
                    Spacer()
                    Text("Set : " + String(setNum))
                        .font(.custom("Avenir Next Condensed", size : 36))
                    Spacer()
                }
                .padding(.top, 50)
                HStack() {
                    Text("Name")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth : .infinity)
                    Text("Weight")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth : .infinity)
                    Text("Reps")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth : .infinity)
                }
                .font(.custom("Avenir Next Condensed", size : 16))
                .padding()
                ScrollView(.vertical) {
                    ForEach(Array(zip(workouts.indices, workouts)), id : \.0) { index, workout in
                        VStack(spacing : 0) {
                            HStack() {
                                Text(workout.name)
                                    .font(.custom("Avenir Next Condensed", size : 16))
                                    .frame(maxWidth : .infinity)
                                    .foregroundColor(Color.black)
                                    .padding(.leading, 5)
                                CustomInputTextField(text : $weights[index])
                                    .background(workout.reps.count >= setNum ? Color.white : Color.gray)
                                    .cornerRadius(15)
                                    .overlay(RoundedRectangle(cornerRadius : 15).stroke(Color.black, lineWidth : 1))
                                    .padding()
                                CustomInputTextField(text : $reps[index])
                                    .background(workout.reps.count >= setNum ? Color.white : Color.gray)
                                    .cornerRadius(15)
                                    .overlay(RoundedRectangle(cornerRadius : 15).stroke(Color.black, lineWidth : 1))
                                    .padding()
                            }
                            .frame(maxWidth : .infinity, minHeight : 50)
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding()
                            .compositingGroup()
                            .allowsHitTesting(!startRest && workout.reps.count >= setNum)
                            if let prevWeight = prevWorkout[workout.name]?[0], let prevReps = prevWorkout[workout.name]?[1] {
                                HStack() {
                                    Image(systemName : "info.circle")
                                        .foregroundColor(Color.blue)
                                    Text("Previous - \(prevWeight)lb at \(prevReps) reps.")
                                        .foregroundColor(Color.black)
                                    Spacer()
                                }
                                .font(.custom("Avenir Next Condensed", size : 14))
                                .padding(.leading, 10)
                            }
                        }
                    }
                }
                HStack() {
                    Spacer()
                    Button(action : {
                        if self.isValid() {
                            startRest = true
                            startTimer = true
                            missingExercise = false
                        }
                        else {
                            missingExercise = true
                        }
                    }) {
                        VStack() {
                            Image(systemName : "chevron.down")
                                .font(.custom("", size : 24))
                        }
                        .padding()
                        .frame(width : 300, height : 45
                        )
                        .background(startRest ? Color(red: 169/255, green: 169/255, blue: 169/255) : Color.black)
                        .cornerRadius(40)
                        .foregroundColor(Color.white)
                    }
                    .allowsHitTesting(!startRest)
                    Spacer()
                }
                if missingExercise {
                    HStack() {
                        Image(systemName : "info.circle")
                            .font(.custom("", size : 18))
                            .foregroundColor(Color.blue)
                        Text("Please fill out the Rep and Weight fields above.")
                            .font(.custom("Avenir Next Condensed", size : 18))
                            .foregroundColor(Color.red)
                    }
                }
                Divider()
                    .frame(height : 3, alignment: .center)
                    .background(Color.blue)
                HStack() {
                    Button(action : {
                        startRest = false
                    }) {
                        VStack() {
                            Image(systemName : "arrow.up")
                                .foregroundColor(Color.black)
                            Text("Edit")
                                .fontWeight(.semibold)
                                .font(.custom("Avenir Next Condensed", size : 14))
                        }
                        .frame(maxWidth : 130)
                        .background(startRest ? Color.green : Color(red: 169/255, green: 169/255, blue: 169/255))
                        .cornerRadius(40)
                    }
                    .allowsHitTesting(startRest)
                    Spacer()
                    Image(systemName : "bed.double")
                        .font(.custom("Avenir Next Condensed", size : 64))
                        .padding()
                    Spacer()
                    Button(action : {
                        self.updateData()
                        skipRest = true
                        timeRemaining = 0
                        if setNum == maxSet(workouts) {
                            self.finishedExercises()
                        }
                    }) {
                        HStack() {
                            Text("Skip Rest")
                                .fontWeight(.semibold)
                                .font(.custom("Avenir Next Condensed", size : 14))
                                .foregroundColor(Color.black)
                            Image(systemName : "arrow.right")
                                .foregroundColor(Color.black)
                        }
                        .frame(maxWidth : 130, maxHeight : 36)
                        .background(startRest ? Color.blue : Color(red: 169/255, green: 169/255, blue: 169/255))
                        .cornerRadius(40)
                    }
                    .allowsHitTesting(startRest)
                    .fullScreenCover(isPresented : $skipRest) {
                        if setNum == maxSet(workouts) {
                            TabView {
                                NavigationView {
                                    workoutSelection(viewModel : self.model)
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
                        else {
                            beginWorkout(timeRemaining: self.model.restTime(exerciseList : workouts, curSet : setNum + 1), setNum: setNum + 1, workouts: self.workouts, model: self.model)
                        }
                    }
                }
                Text("\(timeRemaining)s")
                    .frame(width : 300)
                    .background(startRest || startTimer ? Color.white : Color(red: 169/255, green: 169/255, blue: 169/255))
                    .foregroundColor(Color.blue)
                    .font(.custom("Avenir Next Condensed", size : 64))
                    .cornerRadius(20)
                    .allowsHitTesting(startRest || startTimer)
                    .onReceive(timer) { (_) in
                        if self.timeRemaining > 0 && startRest == true {
                            self.timeRemaining -= 1
                        }
                        else if self.timeRemaining == 0 {
                            timerFinished = true
                        }
                    }
                Button(action : {
                    self.updateData()
                    nextExercise.toggle()
                    if setNum == maxSet(workouts) {
                        self.finishedExercises()
                    }
                }) {
                    HStack() {
                        if setNum == maxSet(workouts) {
                            Text("Finish Exercise")
                                .font(.custom("Avenir Next Condensed", size : 24))
                        }
                        else {
                            Text("Next Set")
                                .font(.custom("Avenir Next Condensed", size : 24))
                        }
                        Image(systemName : "arrow.turn.up.right")
                            .font(.custom("Avenir Next Condensed", size :16))
                    }
                    .frame(width : 300)
                    .background(startTimer && timerFinished ? Color.blue : Color(red: 169/255, green: 169/255, blue: 169/255))
                    .cornerRadius(10)
                    .foregroundColor(Color.black)
                    .padding(.top, 10)
                    .padding(.bottom, 50)
                }
                .allowsHitTesting(startTimer && timerFinished)
                .fullScreenCover(isPresented : $nextExercise) {
                    if setNum == maxSet(workouts) {
                        TabView {
                            NavigationView {
                                workoutSelection(viewModel : self.model)
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
                    else {
                        beginWorkout(timeRemaining: self.model.restTime(exerciseList : workouts, curSet : setNum + 1), setNum: setNum + 1, workouts: self.workouts, model: self.model)
                    }
                }
                Spacer()
            }
            .onAppear() {
                var tempWeight = [String]()
                var tempReps = [String]()
                for workout in workouts {
                    if workout.reps.count >= setNum {
                        tempWeight.append("")
                        tempReps.append(workout.reps[setNum - 1])
                    }
                    else {
                        tempWeight.append("")
                        tempReps.append("")
                    }
                }
                //Populate weights and reps with the default size and elements
                weights = tempWeight
                reps = tempReps
                self.prevData() { res in
                    self.prevWorkout = res
                }
            }
        }
        .background(Color(red: 240/255, green: 240/255, blue: 240/255))
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        //Check how many seconds it has been since the user has left the app and entered the app
        .onReceive(NotificationCenter.default.publisher(for : UIApplication.willResignActiveNotification)) { _ in
            leaveApp = NSDate().timeIntervalSince1970
        }
        .onReceive(NotificationCenter.default.publisher(for : UIApplication.willEnterForegroundNotification)) { _ in
            let dif = Int(NSDate().timeIntervalSince1970 - leaveApp)
            if startRest {
                timeRemaining -= dif
            }
            if timeRemaining < 0 {
                timeRemaining = 0
            }
        }
    }
    func finishedExercises() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from : date)
        for workout in workouts {
            model.completedWorkouts.append(workout.name)
        }
        Firestore.firestore().collection("users/user1/completedWorkouts").document(result).setData([
            "data" : model.completedWorkouts
        ]) { err in
            if let err = err {
                print("Error updating data \(err)")
            }
        }
    }
    
    func maxSet(_ currExercise : [Workout]) -> Int {
        var ans = 0
        for workout in currExercise {
            if workout.reps.count > ans {
                ans = workout.reps.count
            }
        }
        return ans
    }
    
    func prevData(completion : @escaping((Dictionary<String, [String]>) -> ())) {
        var ans = Dictionary<String, [String]>()
        let g = DispatchGroup()
        for workout in workouts {
            g.enter()
            let ref = Firestore.firestore().collection("users/user1/workoutData/" + workout.name + "/prevData").whereField("setNumber", isEqualTo: setNum).order(by : "timeSince1970", descending: true).limit(to : 1)
            ref.getDocuments() { (QuerySnapshot, err) in
                if let err = err {
                    print("Error getting docs : \(err)")
                    g.leave()
                }
                else {
                    if QuerySnapshot!.documents.count > 0 {
                        for document in QuerySnapshot!.documents {
                            let data = document.data()
                            let weight = data["weight"] as? String ?? ""
                            let rep = data["reps"] as? String ?? ""
                            ans[workout.name] = [weight, rep]
                            g.leave()
                        }
                    }
                    else {
                        print("\(workout.name) - This query has 0 documents")
                        g.leave()
                    }
                }
            }
        }
        g.notify(queue: .main) {
            completion(ans)
        }
    }
    
    func updateData() {
        for (index, workout) in workouts.enumerated() {
            //If this exercise had a set for the current setNumber
            if reps[index] != "" {
                let db = Firestore.firestore()
                let isSuperset = workout.version == 0 ? false : true
                db.collection("users/user1/workoutData").document(workout.name).getDocument() { (doc, err) in
                    if let doc = doc, doc.exists {}
                    else {
                        db.collection("users/user1/workoutData").document(workout.name).setData(["foo" : "1"])
                    }
                }
                
                db.collection("users/user1/workoutData/" + workout.name + "/prevData").document(String(NSDate().timeIntervalSince1970)).setData([
                    "isSuperSet" : isSuperset,
                    "weight" : weights[index],
                    "reps" : reps[index],
                    "setNumber" : setNum,
                    "timeSince1970" : String(NSDate().timeIntervalSince1970)
                ]) { err in
                    if let err = err {
                        print("Error updating data \(err)")
                    }
                }
            }
        }
    }
    
    func isValid() -> Bool {
        for (inputWeight, (inputReps, workout)) in zip(weights, zip(reps, workouts)) {
            if workout.reps.count >= setNum {
                if !inputWeight.isInt || !inputReps.isInt {
                    return false
                }
            }
        }
        return true
    }
}

struct CustomInputTextField : UIViewRepresentable {

    @Binding var text: String

    let textField = UITextField() // just any
    func makeUIView(context: UIViewRepresentableContext<CustomInputTextField>) -> UITextField {
        textField.textAlignment = .center
        textField.font = UIFont(name : "Avenir Next Condensed", size : 32)
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomInputTextField>) {
        self.textField.text = text
    }

    func makeCoordinator() -> CustomInputTextField.Coordinator {
        let coordinator = Coordinator(self)

        // configure a toolbar with a Done button
        let toolbar = UIToolbar()
        toolbar.setItems([
            // just moves the Done item to the right
            UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace
                , target: nil
                , action: nil
            )
            , UIBarButtonItem(
                title: "Done"
                , style: UIBarButtonItem.Style.done
                , target: coordinator
                , action: #selector(coordinator.onSet)
            )
            ]
            , animated: true
        )
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()

        textField.inputAccessoryView = toolbar
        return coordinator
    }

    typealias UIViewType = UITextField

    class Coordinator: NSObject {
        let owner: CustomInputTextField
        private var subscriber: AnyCancellable

        init(_ owner: CustomInputTextField) {
            self.owner = owner
            subscriber = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: owner.textField)
                .sink(receiveValue: { _ in
                    owner.$text.wrappedValue = owner.textField.text ?? ""
                })
        }

        @objc fileprivate func onSet() {
            owner.textField.resignFirstResponder()
        }

    }
}
