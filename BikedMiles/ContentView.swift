//
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    @State private var milesBikedLastYear: Double?
    @State private var milesBikedThisYear: Double?
    @State private var isAuthorized = false
    
    let healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack {
            Text("🚴‍♀️") // Bike emoji
                .font(.largeTitle)
            if isAuthorized {
                Text("Miles Biked Last Year: \(milesBikedLastYear ?? 0)")
                Text("Miles Biked This Year: \(milesBikedThisYear ?? 0)")
            }
        }
        .onAppear() {
            fetchMilesBikedLastYear()
            fetchMilesBikedThisYear()
        }
        .padding()
    }
    
    func fetchMilesBikedLastYear() {
        print("fetch step count")
        print("requesting Authorization")
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.isAuthorized = true
            } else {
                print("Authorization error")
                print(error)
            }
        }
        
        healthKitManager.milesBikedLastYear { miles, error in
            print(miles)
            self.milesBikedLastYear = miles
            print(error)
        }
    }
    func fetchMilesBikedThisYear() {
        print("fetch step count")
        print("requesting Authorization")
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.isAuthorized = true
            } else {
                print("Authorization error")
                print(error)
            }
        }
        
        healthKitManager.milesBikedThisYear { miles, error in
            print(miles)
            self.milesBikedThisYear = miles
            print(error)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

