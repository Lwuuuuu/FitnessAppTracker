//
//  RangeView.swift
//  FitnessApp
//
//  Created by Kelley Wu on 12/16/20.
//

import SwiftUI

struct RangeView: View {
    @Binding var rangeNumbers : [String]
    var body: some View {
        HStack {
            VStack {
                Text("Min")
                    .padding(EdgeInsets(top : 20, leading : 20, bottom : 0, trailing: 20))
                InputNumberView(inputNumber: $rangeNumbers[0])
            }
            Spacer()
            VStack {
                Text("Max")
                    .padding(EdgeInsets(top : 20, leading : 20, bottom : 0, trailing: 20))
                InputNumberView(inputNumber: $rangeNumbers[1])
            }
        }
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
        .cornerRadius(15)
        .padding(EdgeInsets(top : 0, leading : 20, bottom : 20, trailing: 20))
    }
}

struct RangeView_Previews: PreviewProvider {
    static var previews: some View {
        RangeView(rangeNumbers : .constant(["0", "0"]))
    }
}

struct InputNumberView : View {
    @Binding var inputNumber : String
    @State var test = 0
    var body : some View {
        HStack(spacing : 0) {
            StepperButton(inputNumber: self.$inputNumber, buttonSign: "-")
            TextField("", text : $inputNumber)
                .multilineTextAlignment(.center)
                .frame(width : 50, height : 30)
                .border(Color.black.opacity(0.4), width : 1)
            StepperButton(inputNumber: self.$inputNumber, buttonSign: "+")
        }
        .padding(EdgeInsets(top : 0, leading : 20, bottom : 20, trailing: 20))
    }
}

struct StepperButton : View {
    @Binding var inputNumber : String
    var buttonSign : String
    var body : some View {
        Button(action : {
            if buttonSign == "-" {
                inputNumber = String(Int(inputNumber)! - 1)
            }
            else {
                inputNumber = String(Int(inputNumber)! + 1)
            }
        })
        {
            Text(buttonSign)
                .foregroundColor(Color.black)
                .frame(width : 30, height : 30)
                .border(Color.black, width : 1)
        }
    }
}
