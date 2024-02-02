//
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    @State private var milesBiked: [Int: Double] = [:]
//    @State private var milesFoot: [Int: Double] = [:]
    @State private var isAuthorized = false
    
    let healthKitManager = HealthKitManager()
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
//            Text("🏃‍♂️ Miles by Foot").font(.largeTitle)
//            if isAuthorized {
//                Text("Last Year: \(numberFormatter.string(from: NSNumber(value: milesFoot[2023] ?? 0))!)")
//                Text("This Year: \(numberFormatter.string(from: NSNumber(value: milesFoot[2024] ?? 0))!)")
//            } else {
//                Text("Unable to access HealthKit")
//            }
            Text("🚴‍♀️ Miles by Bike").font(.largeTitle)
            if isAuthorized {
                Text("Last Year: \(numberFormatter.string(from: NSNumber(value: milesBiked[2023] ?? 0))!)")
                Text("This Year: \(numberFormatter.string(from: NSNumber(value: milesBiked[2024] ?? 0))!)")
            } else {
                Text("Unable to access HealthKit")
            }
        }
        .onAppear() {
            fetchMilesData()
        }
        .padding()
    }
    
    private func fetchMilesData() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.isAuthorized = true
            } else {
                print("Authorization error")
                print(error)
            }
        }
        let years = [2023, 2024]
        for year in years {
            healthKitManager.fetchMilesByBike(year: year) { miles, error in
                self.milesBiked[year] = miles
                print(error)
            }
//            healthKitManager.fetchMilesByFoot(year: year) { miles, error in
//                self.milesFoot[year] = miles
//                print(error)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

