//
//  CustomPickerView.swift
//  FitnessApp
//
//  Created by Kelley Wu on 12/16/20.
//

import SwiftUI

struct CustomPickerView: View {
    var items : [String]
    @State private var filteredItems : [String] = []
    @State private var filterString : String = ""
    @State private var frameHeight : CGFloat = 400
    @Binding var pickerField : String
    @Binding var presentPicker : Bool
    var body: some View {
        let filterBinding = Binding<String> (
            get: { filterString },
            set: {
                filterString = $0
                if filterString != "" {
                    filteredItems = items.filter{$0.lowercased().contains(filterString.lowercased())}
                }
                else {
                    filteredItems = items
                }
                setHeight()
            }
        )
        ZStack {
            Color.black.opacity(0.4)
            VStack {
                VStack(alignment : .leading, spacing : 5) {
                    HStack() {
                        Button( action : {
                            withAnimation {
                                presentPicker = false
                            }
                        })
                        {
                            Text("Cancel")
                        }
                        .padding(10)
                        Spacer()
                    }
                    .background(Color(UIColor.darkGray))
                    .foregroundColor(Color.white)
                    TextField("Filter by entering text", text : filterBinding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    List {
                        ForEach(filteredItems, id :\.self) { item in
                            Button(action : {
                                pickerField = item
                                withAnimation {
                                    presentPicker = false
                                }
                            })
                            {
                                Text(item)
                            }
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .frame(maxWidth : 400)
                .padding(.horizontal, 10)
                .frame(height : frameHeight)
                .padding(.top, 40)
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            filteredItems = items
            setHeight()
        }
    }
    fileprivate func setHeight() {
        withAnimation {
            if filteredItems.count > 5 {
                frameHeight = 400
            }
            else if filteredItems.count == 0 {
                frameHeight = 130
            }
            else {
                frameHeight = CGFloat(filteredItems.count * 45 + 130)
            }
        }
    }
}

struct CustomPickerView_Previews: PreviewProvider {
    static let sampleData = ["Bench Press", "Easy Bar Row", "Incline Dumbbell Press", "Pull Ups", "Overhead Press"].sorted()
    static var previews: some View {
        CustomPickerView(items : sampleData, pickerField : .constant(""), presentPicker : .constant(true))
    }
}
