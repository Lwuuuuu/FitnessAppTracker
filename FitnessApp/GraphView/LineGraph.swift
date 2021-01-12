//
//  LineGraph.swift
//  FitnessApp
//
//  Created by Kelley Wu on 1/6/21.
//

import SwiftUI
import SwiftUICharts
import FirebaseFirestore

struct LineGraph: View {
    @State var currentData : Double = 0 
    var name : String
    var weights : [String]
    var reps : [String]
    @State var data = Dictionary<String, [ExerciseData]>()
    @State var currentIndex = -1
    @State var dataPoints = [Double]()
    var body: some View {
        VStack {
            LineView(data : self.dataPoints, title : name, legend : "General", currentIndex : self.$currentIndex)
                .padding()
            if currentIndex != -1 {
                HStack {
                    Text("Set")
                        .frame(maxWidth : .infinity)
                    Text("Weight")
                        .frame(maxWidth : .infinity)
                    Text("Reps")
                        .frame(maxWidth : .infinity)
                }
                .font(.custom("Avenir Next Condensed", size : 32))
                .padding(.top, 150)
                ScrollView(.vertical) {
                    ForEach(self.data[Array(self.data.keys).sorted(by: <)[currentIndex]]!, id : \.self) { element in
                        HStack {
                            Text(String(element.setNum))
                                .frame(maxWidth : .infinity)
                            Text(element.weight)
                                .frame(maxWidth : .infinity)
                            Text(element.reps)
                                .frame(maxWidth : .infinity)
                        }
                        .font(.custom("Avenir Next Condensed", size : 32))
                    }
                }
                HStack {
                    Spacer()
                    let date = findDate()
                    Text("Date " + date)
                        .font(.custom("Avenir Next Condensed", size : 32))
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text(String(currentIndex + 1) + "/" + String(dataPoints.count))
                        .font(.custom("Avenir Next Condensed", size : 16))
                    Spacer()
                }
            }
        }
        .onAppear() {
            self.getData() { res in
                self.data = res
                for key in Array(self.data.keys).sorted(by: <) {
                    var totalWeight = 0
                    var totalReps = 0
                    for i in 0..<(data[key]!.count) {
                        let reps = Int(data[key]![i].reps)!
                        totalWeight += Int(data[key]![i].weight)! * Int(data[key]![i].reps)!
                        totalReps += reps
                    }
                    if totalWeight == 0 {
                        self.dataPoints.append(Double(totalReps) / Double(data[key]!.count))
                    }
                    else {
                        self.dataPoints.append((Double(totalWeight) / Double(totalReps)) * (1.00 - 1.00/Double(totalReps)))
                    }
                }
            }
        }
    }
    func getData(completion : @escaping((Dictionary<String, [ExerciseData]>) -> ())) {
        var ans = Dictionary<String, [ExerciseData]>()
        let db = Firestore.firestore()
        let g = DispatchGroup()
        g.enter()
        db.collection("users/user1/workoutData/" + name + "/prevData").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting docs : \(err)")
                g.leave()
            }
            else {
                for document in QuerySnapshot!.documents {
                    let data = document.data()
                    let isSuperset = data["isSuperSet"] as? Bool ?? false
                    let weight = data["weight"] as? String ?? ""
                    let reps = data["reps"] as? String ?? ""
                    let setNum = data["setNumber"] as? Int ?? -1
                    let temp = ExerciseData(isSuperset, reps, setNum, weight)
                    let daysSince1970 = String(Int(Double(document.documentID)! / 86400))
                    if ans.keys.contains(daysSince1970) {
                        ans[daysSince1970]!.append(temp)
                    }
                    else {
                        ans[daysSince1970] = [temp]
                    }
                }
                g.leave()
            }
        }
        g.notify(queue: .main) {
            completion(ans)
        }
    }
    func findDate() -> String {
        let time = Array(self.data.keys).sorted(by: <)[currentIndex]
        let date = NSDate(timeIntervalSince1970: (Double(time)! * 86400))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateasString = dateFormatter.string(from : date as Date)
        print("Date" + dateasString)
        return dateasString
        
    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        LineGraph(name : "hello", weights : ["1", "2"], reps : ["10, 20"])
    }
}
