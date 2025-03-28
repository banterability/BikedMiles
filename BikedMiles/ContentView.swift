//
//  ContentView.swift

import SwiftUI

struct StatCard: View {
    let title: String
    let lastPeriod: String
    let currentPeriod: String
    let lastValue: Double
    let currentValue: Double
    let formatter: NumberFormatter
    
    private var percentChange: Double {
        guard lastValue > 0 else { return 0 }
        return ((currentValue - lastValue) / lastValue) * 100
    }
    
    private var formattedPercentChange: String {
        let absChange = abs(percentChange)
        let formattedValue = String(format: "%.1f", absChange)
        return "\(percentChange >= 0 ? "+" : "-")\(formattedValue)%"
    }
    
    private func formatMiles(_ value: Double) -> String {
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(alignment: .top, spacing: 20) {
                // Last period stats
                VStack(alignment: .leading, spacing: 4) {
                    Text(lastPeriod)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(formatMiles(lastValue)) mi")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Current period stats
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentPeriod)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .center, spacing: 4) {
                        Text("\(formatMiles(currentValue)) mi")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if lastValue > 0 {
                            HStack(spacing: 2) {
                                getTrendIcon(lastValue: lastValue, currentValue: currentValue)
                                Text(formattedPercentChange)
                                    .font(.caption)
                                    .foregroundColor(
                                        currentValue > lastValue ? .green :
                                        currentValue < lastValue ? .red : .gray
                                    )
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func getTrendIcon(lastValue: Double, currentValue: Double) -> some View {
        if currentValue > lastValue {
            return Image(systemName: "arrow.up")
                .foregroundColor(.green)
        } else if currentValue < lastValue {
            return Image(systemName: "arrow.down")
                .foregroundColor(.red)
        } else {
            return Image(systemName: "arrow.forward")
                .foregroundColor(.gray)
        }
    }
}

struct ContentView: View {
    @State private var milesBiked: [String: Double] = [:]
    @State private var isAuthorized = false

    let healthKitManager = HealthKitManager()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
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
            Text("🚴‍♀️ Miles by Bike")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)
                .padding(.bottom, 20)

            if isAuthorized {
                ScrollView {
                    VStack(spacing: 25) {
                        // Weekly Stats
                        StatCard(
                            title: "Weekly Stats",
                            lastPeriod: "Last Week",
                            currentPeriod: "This Week",
                            lastValue: milesBiked["lastWeek"] ?? 0,
                            currentValue: milesBiked["thisWeek"] ?? 0,
                            formatter: numberFormatter
                        )
                        
                        // Monthly Stats
                        StatCard(
                            title: "Monthly Stats",
                            lastPeriod: "Last Month",
                            currentPeriod: "This Month",
                            lastValue: milesBiked["lastMonth"] ?? 0,
                            currentValue: milesBiked["thisMonth"] ?? 0,
                            formatter: numberFormatter
                        )
                        
                        // Yearly Stats
                        StatCard(
                            title: "Yearly Stats",
                            lastPeriod: "Last Year",
                            currentPeriod: "This Year",
                            lastValue: milesBiked["lastYear"] ?? 0,
                            currentValue: milesBiked["thisYear"] ?? 0,
                            formatter: numberFormatter
                        )
                    }
                    .padding()
                }
            } else {
                Spacer()
                Text("Unable to access HealthKit")
                    .font(.headline)
                    .foregroundColor(.red)
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .padding()
                Text("Please grant BikedMiles access to HealthKit data in your device settings.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
        }
        .background(Color(.systemBackground))
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
        do {
            let (currentMonthYear, currentMonth) = try currentDate.thisMonth()
            let (lastMonthYear, lastMonth) = try currentDate.lastMonth()
            let previousYear = try currentDate.lastYear()
            let currentWeek = try currentDate.thisWeek()
            let lastWeek = try currentDate.lastWeek()

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