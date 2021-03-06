//
//  WorkoutModel.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/4/20.
//
import SwiftUI
import Foundation
import FirebaseFirestore
class WorkoutModel : ObservableObject {
    var day = ""
    var currWorkout = Dictionary<String, Int>()
    var prevWorkout : [String : Any] = [:]
    @Published var workouts = [Workout]()
    @Published var completedWorkouts = [String]()
    @Published var leftoverWorkouts = Dictionary<String, Int>()
    private var db = Firestore.firestore()
    var topNum : Int = 0
    init() {
        self.cleanseCompletion()
        self.completedExercises()
        self.changeDay(day: self.getTodayWeekDay())
        self.fetchData()
    }
    
    func getTodayWeekDay() -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EEEE"
           let weekDay = dateFormatter.string(from: Date())
           return weekDay
     }
    func findExerciseSet(exerciseName : String) -> [Workout]? {
        let exerciseList = self.orderedExercises()
        for exerciseSet in exerciseList {
            for exercise in exerciseSet {
                if exercise.name == exerciseName {
                    return exerciseSet
                }
            }
        }
        return nil
    }
    
    func updateLeftovers(name : String, set : Int, finished : Bool) {
        if finished {
            self.leftoverWorkouts.removeValue(forKey: name)
        }
        else {
            self.leftoverWorkouts[name] = set
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from : date)
        Firestore.firestore().collection("users/user1/completedWorkouts").document(result).updateData([
            "leftovers" : self.leftoverWorkouts
        ]) { err in
            if let err = err {
                print("Error updating leftover exercise field \(err)")
            }
        }
    }
    func cleanseCompletion() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from : date)
        db.collection("users/user1/completedWorkouts").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting docs : \(err)")
            }
            else {
                for document in QuerySnapshot!.documents {
                    let docId = document.documentID
                    if docId != result {
                        self.db.collection("users/user1/completedWorkouts").document(docId).delete()
                    }
                }
            }
        }
    }
    
    func orderedExercises() -> [[Workout]] {
        var exerciseDict = Dictionary<String, [Workout]>()
        var ans = [[Workout]]()
        for workout in workouts {
            if workout.version == 0 {
                exerciseDict[UUID().uuidString] = [workout]
            }
            else if exerciseDict.keys.contains(String(workout.version)) {
                exerciseDict[String(workout.version)]?.append(workout)
            }
            else {
                exerciseDict[String(workout.version)] = [workout]
            }
        }
        for key in exerciseDict.keys {
            ans.append(exerciseDict[key]!)
        }
        return ans
    }
    
    func restTime(exerciseList : [Workout], curSet : Int)  -> Int {
        if exerciseList.count == 1 {
            print(exerciseList[0].name)
            print(curSet)
            return Int(exerciseList[0].rest[curSet - 1])!
        }
        else {
            var foundExercise = false
            var index = 0
            var restTime = 0
            var exerciseNum = exerciseList.count
            while !foundExercise && index < exerciseList.count {
                if exerciseList[index].order == exerciseNum {
                    if exerciseList[index].rest.count >= curSet {
                        restTime = Int(exerciseList[index].rest[curSet - 1])!
                        foundExercise = true
                    }
                    else {
                        index = 0
                        exerciseNum -= 1
                    }
                }
                else {
                    index += 1
                }
            }
            return restTime
        }
    }
    
    func populateSuperset(num : Int) -> [String : [Int]] {
        var ans = [String : [Int]]()
        for workout in workouts {
            if workout.version == num && num > 0 {
                ans[workout.name] = [workout.version, workout.order]
            }
        }
        return ans
    }
    
    func findlatestOrd(num : Int) -> Int {
        var ans = [Int]()
        for workout in workouts {
            if workout.version == num {
                ans.append(workout.order)
            }
        }
        return ans.max() ?? 0
    }
    
    func latestVer() -> Int {
        var ans = 0
        for workout in workouts {
            if workout.version > ans {
                ans = workout.version
            }
        }
        return ans + 1
    }
    
    func numSets() -> Double {
        var ans = 0
        for workout in workouts {
            ans += workout.reps.count
        }
        return Double(ans)
    }

    func changeDay(day : String) {
        self.day = day
    }
    func getNames() -> Set<String> {
        var ans = Set<String>()
        for workout in workouts {
            ans.insert(workout.name)
        }
        return ans
    }
    
    func possibleSuperset() -> [Workout] {
        var ans = [Workout]()
        for workout in workouts {
            if workout.version == 0 {
                ans.append(workout)
            }
        }
        return ans
    }
    func fetchData() {
        db.collection("users/user1/" + day).addSnapshotListener { [self] (querySnapshot, error) in
            guard let doc = querySnapshot?.documents else {
                print("No workouts found")
                return
            }
            self.workouts = doc.map { (queryDocumentSnapshot) -> Workout in
                let data = queryDocumentSnapshot.data()
                let supersetVer = data["supersetVer"] as? Int ?? -1
                let supersetOrd = data["supersetOrd"] as? Int ?? -1
                let name = data["Name"] as? String ?? ""
                let rest = data["Rest"] as? [String] ?? [""]
                let reps = data["Reps"] as? [String] ?? [""]
                return Workout(name, supersetVer, supersetOrd, reps, rest)
            }
        }
    }
    
    func completedExercises() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from : date)
        db.collection("users/user1/completedWorkouts").document(result).addSnapshotListener { DocumentSnapshot, error in
            guard let document = DocumentSnapshot else {
                print("Error fetching doc \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document empty")
                return
            }
            if let temp = data["data"] {
                self.completedWorkouts = temp as! [String]
            }
            let dict = data["leftovers"] as? [String : Int] ?? [:]
            for exercise in dict.keys {
                self.leftoverWorkouts[exercise] = dict[exercise]
            }
        }
    }
    
    func updateExercise(_ newExercise : Workout, _ isNew : Bool) -> Bool {
        newExercise.reps = newExercise.reps.filter {$0 != ""}
        newExercise.rest = newExercise.rest.filter {$0 != ""}
        var returnStatus = true
        for workout in workouts {
            //Adding an exercise that already exists for that day
            if workout.name == newExercise.name && isNew {
                return false
            }
        }
        db.collection("users/user1/" + day).document(newExercise.name).setData([
            "Name" : newExercise.name,
            "Rest" : newExercise.rest,
            "Reps" : newExercise.reps,
            "supersetOrd" : newExercise.order,
            "supersetVer" : newExercise.version
        ]) { err in
            if let err = err {
                print("Error updating document \(err)")
                returnStatus = false
            }
        }
        return returnStatus
    }
    
    func deleteExercise(name : String) {
        db.collection("users/user1/" + day).document(name).delete()
    }
    
    func updateSuperset(_ superSet : [String : [Int]]) -> Bool {
        var returnStatus = true
        for key in superSet.keys {
            db.collection("users/user1/" + day).document(key).setData([
                "supersetVer" : superSet[key]![0],
                "supersetOrd" : superSet[key]![1]
            ], merge : true) { err in
                if let err = err {
                    print("Error updating document \(err)")
                    returnStatus = false
                }
            }
        }
        return returnStatus
    }
}



