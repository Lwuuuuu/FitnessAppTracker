//
//  LineGraph.swift
//  FitnessApp
//
//  Created by Kelley Wu on 1/6/21.
//

import SwiftUI
import SwiftUICharts

struct LineGraph: View {
    var name : String
    var weights : [String]
    var reps : [String]
    let data : [Double] = [1,2,3,4,5]
    var body: some View {
        VStack {
            LineView(data : [8,23,54,32,12,37,7,23,43], title : "Title", legend : "Full Screen")
                .padding()
        }
    }

    
//    func getData() {
//
//    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        LineGraph(name : "hello", weights : ["1", "2"], reps : ["10, 20"])
    }
}
