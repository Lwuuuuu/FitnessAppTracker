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
    var body: some View {
        ScrollView(.vertical) {
            VStack() {
                DayButton(dayChosen : "Sunday", editButton : $editButton)
                DayButton(dayChosen : "Monday", editButton : $editButton)
                DayButton(dayChosen : "Tuesday", editButton : $editButton)
                DayButton(dayChosen : "Wednesday", editButton : $editButton)
                DayButton(dayChosen : "Thursday", editButton : $editButton)
                DayButton(dayChosen : "Friday", editButton : $editButton)
                DayButton(dayChosen : "Saturday", editButton : $editButton)
                Spacer()
            }
            .padding(.top, 100)
        }
        .background(Color(red: 65/255, green: 74/255, blue: 76/255))
        .ignoresSafeArea(.all)
    }
}




struct EditWorkout_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkout()
    }
}
