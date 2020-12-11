//
//  SetData.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/30/20.
//

import Foundation
import SwiftUI
class SetData : Identifiable, Equatable {
    static func == (lhs : SetData, rhs : SetData) -> Bool {
        lhs.id == rhs.id
    }
    @State var reps : String
    @State var rest : String
//    var reps : String
//    var rest : String
    let id = UUID().uuidString

    init() {
        _reps = State(initialValue: "")
        _rest = State(initialValue: "")
//        self.reps = ""
//        self.rest = ""
    }
    
    init(_ reps : String, _ rest : String) {
        _reps = State(initialValue: reps)
        _rest = State(initialValue: rest)
//        self.reps = reps
//        self.rest = rest
    }
}
