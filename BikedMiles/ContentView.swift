//
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    @State private var milesBiked: [String: Double] = [:]
    @State private var isAuthorized = false

    let healthKitManager = HealthKitManager()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter;
    }()
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            Spacer()
            Text("🚴‍♀️ Miles by Bike").font(.largeTitle).padding([.bottom], 20)

            if isAuthorized {
                VStack{
                    HStack{
                        Text("Last Week:").font(.subheadline).bold()
                        Text(numberFormatter.string(from: NSNumber(value: milesBiked["lastWeek"] ?? 0))!)
                        Text("miles")
                    }.font(.title2)
                    HStack {
                        Text("This Week:").font(.subheadline).bold()
                        Text(numberFormatter.string(from: NSNumber(value: milesBiked["thisWeek"] ?? 0))!)
                        Text("miles")
                    }.font(.title2)
                }.padding([.bottom], 10)
                VStack{
                    HStack{
                        Text("Last Month:").font(.subheadline).bold()
                        Text(numberFormatter.string(from: NSNumber(value: milesBiked["lastMonth"] ?? 0))!)
                        Text("miles")
                    }.font(.title2)
                    HStack {
                        Text("This Month:").font(.subheadline).bold()
                        Text(numberFormatter.string(from: NSNumber(value: milesBiked["thisMonth"] ?? 0))!)
                        Text("miles")
                    }.font(.title2)
                }.padding([.bottom], 10)
                HStack{
                    Text("Last Year:").font(.subheadline).bold()
                    Text(numberFormatter.string(from: NSNumber(value: milesBiked["lastYear"] ?? 0))!)
                    Text("miles")
                }.font(.title2)
                HStack {
                    Text("This Year:").font(.subheadline).bold()
                    Text(numberFormatter.string(from: NSNumber(value: milesBiked["thisYear"] ?? 0))!)
                    Text("miles")
                }.font(.title2)
            } else {
                Text("Unable to access HealthKit")
            }
            Spacer()
        }
        .onAppear() {
            fetchMilesData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            fetchMilesData()
        })
    }

    private func fetchMilesData() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.isAuthorized = true
            } else {
                print("Authorization error")
            }
        }
        let currentDate = Date()
        do{
            let (currentMonthYear, currentMonth) = try currentDate.thisMonth()
            let (lastMonthYear, lastMonth) = try currentDate.lastMonth()
            let previousYear = try currentDate.lastYear()
            let currentWeek = try currentDate.thisWeek();
            let lastWeek = try currentDate.lastWeek();

            healthKitManager.fetchMilesByBikeForWeek(year: lastWeek.year, month: lastWeek.month, day: lastWeek.day) { miles, error in self.milesBiked["lastWeek"] = miles}
            healthKitManager.fetchMilesByBikeForWeek(year: currentWeek.year, month: currentWeek.month, day: currentWeek.day) { miles, error in self.milesBiked["thisWeek"] = miles}
            healthKitManager.fetchMilesByBikeForMonth(year: lastMonthYear, month: lastMonth) { miles, error in self.milesBiked["lastMonth"] = miles}
            healthKitManager.fetchMilesByBikeForMonth(year: currentMonthYear, month: currentMonth) { miles, error in self.milesBiked["thisMonth"] = miles}
            healthKitManager.fetchMilesByBikeForYear(year: previousYear) { miles, error in self.milesBiked["lastYear"] = miles}
            healthKitManager.fetchMilesByBikeForYear(year: currentMonthYear) { miles, error in self.milesBiked["thisYear"] = miles}
        } catch {
           print("An error occurred while calculating dates: \(error)")

       }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

