//
//  ExerciseEdit.swift
//  FitnessApp
//
//  Created by Kelley Wu on 10/30/20.
//

import SwiftUI
import Firebase

struct ExerciseEdit : View {
    var chosenDay : String
    var workouts : [String : [String : Int]]
    var testdict : [String : Int] = ["Never" : 10, "Ever" : 5]
    var body: some View {
        let keys = workouts.map{$0.key}
        let values = workouts.map {$0.value}
        return List {
            ForEach(keys.indices) {index in
                HStack {
                    Text(keys[index])
//                    ForEach(values[index].keys)
                    Text("\(values[index]["ok"]!)")
                }
            }
        }
    }
}

struct ExerciseEdit_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseEdit(chosenDay : "Sunday", workouts : ["rip" : ["ok" : 0]]
        )
    }
}
