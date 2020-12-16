//
//  EditView.swift
//  FitnessApp
//
//  Created by Kelley Wu on 11/8/20.
//

import SwiftUI
import Combine
import UIKit

extension String {
    var isInt : Bool {
        return Int(self) != nil
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


struct EditView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var newName = ""
    @State var showAlert = false
    @State var invalidInput = false
    @State var addSuperset = false
    @State var buttonPressed = false
    @State var editButton = false
    @State var isNew = false
    @State var selectedElement = [String]()
    @State var exInfo = [[String]]()
    var model : Workout
    @ObservedObject var viewModel : WorkoutModel
    @State var superSet = [String : [Int]]()
    var body: some View {
        ZStack() {
            Color(red : 240/255, green : 240/255, blue : 240/255)
                .ignoresSafeArea(.all)
            VStack(spacing : 0) {
                VStack(spacing : -5) {
                    HStack() {
                        if model.name == "" {
                            TextField("New Exercise", text : $newName)
                                .background(Color(red : 85/255, green : 85/255, blue : 85/255))
                                
                        }
                        else {
                            Text(model.name)
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                    }
                    .font(.custom("Avenir Next Condensed", size : 36))
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 10)
                    Rectangle()
                        .fill(Color.orange)
                        .frame(maxWidth : .infinity, maxHeight: 2)
                        .edgesIgnoringSafeArea(.horizontal)
                }
                HStack() {
                    Text("Reps")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth : .infinity)
                        .padding(.leading, 30)
                    Text("Rest")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth : .infinity)
                        .padding(.trailing, 30)
                }
                .font(.custom("Avenir Next Condensed", size : 32))
                List {
                    ForEach(Array(zip(exInfo.indices, exInfo)), id : \.0) { index, data in
                        EditorView(container : self.$exInfo, text : Binding(get : {self.exInfo[index]}, set : {self.exInfo[index] = $0}))
                    }.onDelete { indexSet in
                        self.exInfo.remove(atOffsets : indexSet)
                    }
                    Button(action: {
                        exInfo.append([UUID().uuidString, "", ""])

                    })
                    {
                        HStack(alignment : .center) {
                            Spacer()
                            Image(systemName : "plus.circle")
                            Text("Add a Set")
                            Spacer()
                        }
                        .font(.custom("Avenir Next Condensed", size : 24))
                        .foregroundColor(Color.orange)
                    }
                }
                Rectangle()
                    .fill(Color.orange)
                    .frame(maxWidth : .infinity, maxHeight: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                Spacer()
                HStack() {
                    Button(action : {
                        print("Button pressed")
                        buttonPressed.toggle()
                    })
                    {
                        Image(systemName : "ellipsis.circle")
                            .font(.system(size : 60))
                            .foregroundColor(Color.orange)
                            .padding()
                        
                    }
                    Spacer()
                    Button(action: {
                        var repList = [String]()
                        var restList = [String]()
                        for element in exInfo {
                            repList.append(element[1])
                            restList.append(element[2])
                        }
                        if repList.allSatisfy({ $0.isInt }) && restList.allSatisfy({$0.isInt}) {
                            let updatedEx = newName != "" ? newName : model.name
                            let newEx = newName != "" ? true : false
                            let supersetVersion = superSet.count <= 1 ? 0 : superSet[updatedEx]![0]
                            let supersetOrder = superSet.count <= 1 ? 0 : superSet[updatedEx]![1]
                            superSet.removeValue(forKey: updatedEx)
                            //Remove updatedEx from dictionary here and then call function to update database for the remainingf superset exercise version/order
                            if viewModel.updateExercise(Workout(updatedEx, supersetVersion, supersetOrder, repList, restList), newEx) && viewModel.updateSuperset(superSet) {
                                print("Successfully saved to Database.")
                                self.dismiss()
                            }
                            else {
                                self.showAlert.toggle()
                            }
                        }
                        else {
                            self.invalidInput.toggle()
                        }
                    })
                    {
                        Text("Save")
                            .font(.custom("Avenir Next Condensed", size : 36))
                            .frame(width : 100)
                            .background(Color.orange)
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                            .padding()
                    }
                }
            }
            .foregroundColor(Color.gray)
        }
        .sheet(isPresented : self.$buttonPressed) {
            PopupMenu(viewModel : self.viewModel, workout : model, possibleSuperset : self.viewModel.possibleSuperset(), superSet : self.$superSet, isNew : $isNew)
        }
        .onAppear() {
            for (x, y) in zip(model.reps, model.rest) {
                exInfo.append([UUID().uuidString, x, y])
            }
            self.superSet = viewModel.populateSuperset(num : model.version)
            if model.name == "" {
                isNew = true
            }
        }
        .navigationBarTitle(Text("Workout Editor"), displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
    .alert(isPresented: self.$showAlert) {
        Alert(title : Text("Duplicate found!"), message : Text("An exercise with this name already exists in this days workout"), dismissButton: .default(Text("Confirm")))
    }
    .alert(isPresented: self.$invalidInput) {
        Alert(title : Text("Invalid Input!"), message : Text("One of the numbers you inputted is not a number"), dismissButton: .default(Text("Confirm")))
    }
    }
    func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct EditorView : View {
    var container : Binding<[[String]]>
    @Binding var text : [String]
    
    var body : some View {
        HStack(alignment : .center, spacing : 0) {
            Spacer()
            InputTextField(text : self.$text[1])
                .frame(maxWidth : .infinity)
                .multilineTextAlignment(.center)
                .overlay (
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth : 1)
                )
                .background(Color(red : 240/255, green : 248/255, blue : 255/255))
                .padding()
            InputTextField(text : self.$text[2])
                .frame(maxWidth : .infinity)
                .multilineTextAlignment(.center)
                .overlay (
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth : 1)
                )
                .background(Color(red : 240/255, green : 248/255, blue : 255/255))
                .padding()
            Spacer()
        }
        .font(.custom("Avenir Next Condensed", size : 26))
        .cornerRadius(15)
//        .listRowBackground(Color.white)
//        .padding()
    }
}

struct InputTextField : UIViewRepresentable {

    @Binding var text: String

    let textField = UITextField() // just any
    func makeUIView(context: UIViewRepresentableContext<InputTextField>) -> UITextField {
        textField.textAlignment = .center
        textField.font = UIFont(name : "Avenir Next Condensed", size : 32)
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<InputTextField>) {
        self.textField.text = text
    }

    func makeCoordinator() -> InputTextField.Coordinator {
        let coordinator = Coordinator(self)

        // configure a toolbar with a Done button
        let toolbar = UIToolbar()
        toolbar.setItems([
            // just moves the Done item to the right
            UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace
                , target: nil
                , action: nil
            )
            , UIBarButtonItem(
                title: "Done"
                , style: UIBarButtonItem.Style.done
                , target: coordinator
                , action: #selector(coordinator.onSet)
            )
            ]
            , animated: true
        )
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()

        textField.inputAccessoryView = toolbar
        return coordinator
    }

    typealias UIViewType = UITextField

    class Coordinator: NSObject {
        let owner: InputTextField
        private var subscriber: AnyCancellable

        init(_ owner: InputTextField) {
            self.owner = owner
            subscriber = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: owner.textField)
                .sink(receiveValue: { _ in
                    owner.$text.wrappedValue = owner.textField.text ?? ""
                })
        }

        @objc fileprivate func onSet() {
            owner.textField.resignFirstResponder()
        }

    }
}
