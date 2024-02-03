//
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    @State private var milesBiked: [Int: Double] = [:]
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
            Text("🚴‍♀️ Miles by Bike").font(.largeTitle)
            if isAuthorized {
                HStack{
                    Text("Last Year:").font(.subheadline).bold()
                    Text(numberFormatter.string(from: NSNumber(value: milesBiked[2023] ?? 0))!)
                    Text("miles")
                }.font(.title2)
                HStack {
                    Text("This Year:").font(.subheadline).bold()
                    Text(numberFormatter.string(from: NSNumber(value: milesBiked[2024] ?? 0))!)
                    Text("miles")
                }.font(.title2)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

