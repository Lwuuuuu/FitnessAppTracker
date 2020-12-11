//
//  ButtonView.swift
//  FitnessApp
//
//  Created by Kelley Wu on 10/30/20.
//

import SwiftUI

struct ButtonView: View {
    @Binding var buttonName : String
    var body: some View {
        Button(action: {
        }) {
            Text(buttonName)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth : .infinity, maxHeight: .infinity)
                .background(Color.black)
                .shadow(color: .white, radius : 2)
        }
        .border(Color.white, width : 1)
        .shadow(color: .blue, radius : 3)
        .cornerRadius(20)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(buttonName : Binding.constant("Workout"))
    }
}
