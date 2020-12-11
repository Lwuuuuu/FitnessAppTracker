//
//  WorkoutBox.swift
//  FitnessApp
//
//  Created by Kelley Wu on 12/3/20.
//

import SwiftUI

struct WorkoutBox: View {
    var body: some View {
        ZStack() {
            Rectangle()
                .fill(Color.black)
                .frame(width : 150, height : 150)
                .edgesIgnoringSafeArea(.horizontal)
                .cornerRadius(30)
            Text("Hello world good bye world")
                .foregroundColor(Color.white)
        }
    }
}

struct WorkoutBox_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutBox()
    }
}
