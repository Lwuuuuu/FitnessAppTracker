//
//  ExerciseData.swift
//  FitnessApp
//
//  Created by Kelley Wu on 1/6/21.
//

import Foundation

class ExerciseData : Hashable, Equatable {
    static func == (lhs : ExerciseData, rhs : ExerciseData) -> Bool {
        lhs.id == rhs.id
    }
    
    var isSuperSet : Bool
    var reps : String
    var setNum : Int
    var weight : String
    var id = UUID().uuidString

    init(_ isSuperSet : Bool, _ reps : String, _ setNum : Int, _ weight : String) {
        self.isSuperSet = isSuperSet
        self.reps = reps
        self.setNum = setNum
        self.weight = weight
    }
    func hash(into hasher : inout Hasher) {
        hasher.combine(id)
    }
}
