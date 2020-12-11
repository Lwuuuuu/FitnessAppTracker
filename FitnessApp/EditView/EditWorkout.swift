//
//  EditWorkout.swift
//  FitnessApp
//
//  Created by Kelley Wu on 10/30/20.
//

import SwiftUI
import UIKit

struct EditWorkout: View {
    @State var editButton = false
    @State var dayofWeek = [true, false, false, false, false, false, false]
    @State var chosenDay = 0
    let listDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let abbrvDays = ["S", "M", "T", "W", "T", "F", "S"]
    var body: some View {
        VStack() {
            HStack() {
                ForEach(Array(zip(listDays.indices, listDays)), id : \.0) { index, data in
                    dayofweekButton(dayList : $dayofWeek, index : index, buttonText: abbrvDays[index], chosenDay : self.$chosenDay)
                }
            }
            DayButton(dayChosen: listDays[chosenDay], editButton: $editButton)
            Spacer()
            
        }
        .padding()
        .navigationBarTitle("Day Selector", displayMode: .inline)
        .background(Color(red : 240/255, green : 240/255, blue : 240/255))
    }
}




struct EditWorkout_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkout()
    }
}

struct dayofweekButton : View {
    @Binding var dayList : [Bool]
    var index : Int
    var buttonText : String
    @Binding var chosenDay : Int
    var body : some View {
        Button(action : {
            dayList = Array(repeating: false, count: 7)
            dayList[index] = true
            chosenDay = index
        })
        {
            Text(buttonText)
                .frame(width : 45, height : 45)
                .foregroundColor(Color.black)
                .background(dayList[index] ? Circle().fill(Color.orange).shadow(radius: 2) :
                    Circle().fill(Color.white).shadow(radius: 2)
                )
        }
    }
}
