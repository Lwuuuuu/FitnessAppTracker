//
//  Workout.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/4/20.
//
import SwiftUI
import Foundation

struct Workout : Identifiable, Equatable, Hashable {
    static func == (lhs : Self, rhs : Self) -> Bool {
        lhs.id == rhs.id
    }
    var name : String
    @State var version : Int
    @State var order : Int
    @State var reps : [String]
    @State var rest : [String]
    var id = UUID().uuidString
    
    init() {
        self.name = ""
        _version = State(initialValue : 0)
        _order = State(initialValue :0)
        _reps = State(initialValue : [""])
        _rest = State(initialValue : [""])
    }
    init(_ name : String, _ version : Int, _ order : Int, _ reps : [String], _ rest : [String]) {
        self.name = name
        _version = State(initialValue : version)
        _order = State(initialValue : order)
        _reps = State(initialValue: reps)
        _rest = State(initialValue: rest)
    }
    
    func hash(into hasher : inout Hasher) {
        hasher.combine(id)
    }
    
    func changeOrder(_ num : Int) {
        order = num
    }
    
    func changeVersion(_ num : Int) {
        version = num
    }
}

