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
    let lastDateRange: String
    let currentDateRange: String
    
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
            
            // Period labels with date ranges
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(lastPeriod)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(lastDateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text(currentPeriod)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(currentDateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Values and trend indicator
            HStack(alignment: .center) {
                // Last period value (left aligned)
                Text("\(formatMiles(lastValue)) mi")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Trend indicator (centered)
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
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                
                // Current period value (right aligned)
                Text("\(formatMiles(currentValue)) mi")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
    @State private var isLoading = false
    @State private var dateRanges: [String: String] = [:]
    @State private var isRefreshing = false

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
            HStack {
                Text("🚴‍♀️ Miles by Bike")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Refresh button
                Button(action: {
                    withAnimation {
                        fetchMilesData()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isLoading)
                }
                .disabled(isLoading)
                .padding(.trailing)
            }
            .padding(.top, 30)
            .padding(.horizontal)
            .padding(.bottom, 10)

            if isAuthorized {
                if isLoading && milesBiked.isEmpty {
                    Spacer()
                    ProgressView("Loading your cycling data...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        // Pull to refresh
                        RefreshControl(coordinateSpaceName: "pullToRefresh", onRefresh: fetchMilesData)
                            .padding(.top, -50)
                        
                        VStack(spacing: 25) {
                            // Weekly Stats
                            StatCard(
                                title: "Weekly Stats",
                                lastPeriod: "Last Week",
                                currentPeriod: "This Week",
                                lastValue: milesBiked["lastWeek"] ?? 0,
                                currentValue: milesBiked["thisWeek"] ?? 0,
                                formatter: numberFormatter,
                                lastDateRange: dateRanges["lastWeek"] ?? "",
                                currentDateRange: dateRanges["thisWeek"] ?? ""
                            )
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["lastWeek"])
                            .animation(.easeIn, value: milesBiked["thisWeek"])
                            
                            // Monthly Stats
                            StatCard(
                                title: "Monthly Stats",
                                lastPeriod: "Last Month",
                                currentPeriod: "This Month",
                                lastValue: milesBiked["lastMonth"] ?? 0,
                                currentValue: milesBiked["thisMonth"] ?? 0,
                                formatter: numberFormatter,
                                lastDateRange: dateRanges["lastMonth"] ?? "",
                                currentDateRange: dateRanges["thisMonth"] ?? ""
                            )
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["lastMonth"])
                            .animation(.easeIn, value: milesBiked["thisMonth"])
                            
                            // Yearly Stats
                            StatCard(
                                title: "Yearly Stats",
                                lastPeriod: "Last Year",
                                currentPeriod: "This Year",
                                lastValue: milesBiked["lastYear"] ?? 0,
                                currentValue: milesBiked["thisYear"] ?? 0,
                                formatter: numberFormatter,
                                lastDateRange: dateRanges["lastYear"] ?? "",
                                currentDateRange: dateRanges["thisYear"] ?? ""
                            )
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["lastYear"])
                            .animation(.easeIn, value: milesBiked["thisYear"])
                        }
                        .padding()
                    }
                    .coordinateSpace(name: "pullToRefresh")
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
        isLoading = true
        isRefreshing = true
        
        healthKitManager.requestAuthorization { success, error in
            if success {
                self.isAuthorized = true
            } else {
                print("Authorization error")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isRefreshing = false
                }
            }
        }
        
        let currentDate = Date()
        do {
            // Calculate date ranges
            let (currentMonthYear, currentMonth) = try currentDate.thisMonth()
            let (lastMonthYear, lastMonth) = try currentDate.lastMonth()
            let currentYear = currentDate.thisYear()
            let previousYear = try currentDate.lastYear()
            let currentWeek = try currentDate.thisWeek()
            let lastWeek = try currentDate.lastWeek()
            
            // Set date ranges for UI display
            if let currentWeekRange = currentDate.weekDateRange(startingFrom: createDate(year: currentWeek.year, month: currentWeek.month, day: currentWeek.day)) {
                self.dateRanges["thisWeek"] = currentWeekRange.formatted
            }
            
            if let lastWeekRange = currentDate.weekDateRange(startingFrom: createDate(year: lastWeek.year, month: lastWeek.month, day: lastWeek.day)) {
                self.dateRanges["lastWeek"] = lastWeekRange.formatted
            }
            
            if let currentMonthRange = currentDate.monthDateRange(year: currentMonthYear, month: currentMonth) {
                self.dateRanges["thisMonth"] = currentMonthRange.formatted
            }
            
            if let lastMonthRange = currentDate.monthDateRange(year: lastMonthYear, month: lastMonth) {
                self.dateRanges["lastMonth"] = lastMonthRange.formatted
            }
            
            if let currentYearRange = currentDate.yearDateRange(year: currentYear) {
                self.dateRanges["thisYear"] = currentYearRange.formatted
            }
            
            if let lastYearRange = currentDate.yearDateRange(year: previousYear) {
                self.dateRanges["lastYear"] = lastYearRange.formatted
            }
            
            // Create a dispatch group to track when all fetch operations complete
            let group = DispatchGroup()
            
            // Fetch weekly data
            group.enter()
            healthKitManager.fetchMilesByBikeForWeek(year: lastWeek.year, month: lastWeek.month, day: lastWeek.day) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastWeek"] = miles
                    group.leave()
                }
            }
            
            group.enter()
            healthKitManager.fetchMilesByBikeForWeek(year: currentWeek.year, month: currentWeek.month, day: currentWeek.day) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["thisWeek"] = miles
                    group.leave()
                }
            }
            
            // Fetch monthly data
            group.enter()
            healthKitManager.fetchMilesByBikeForMonth(year: lastMonthYear, month: lastMonth) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastMonth"] = miles
                    group.leave()
                }
            }
            
            group.enter()
            healthKitManager.fetchMilesByBikeForMonth(year: currentMonthYear, month: currentMonth) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["thisMonth"] = miles
                    group.leave()
                }
            }
            
            // Fetch yearly data
            group.enter()
            healthKitManager.fetchMilesByBikeForYear(year: previousYear) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastYear"] = miles
                    group.leave()
                }
            }
            
            group.enter()
            healthKitManager.fetchMilesByBikeForYear(year: currentMonthYear) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["thisYear"] = miles
                    group.leave()
                }
            }
            
            // When all fetches complete, update the loading state
            group.notify(queue: .main) {
                withAnimation {
                    self.isLoading = false
                    self.isRefreshing = false
                }
            }
            
        } catch {
            print("An error occurred while calculating dates: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.isRefreshing = false
            }
        }
    }
    
    // Helper to create a Date from components
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

// Pull-to-refresh control
struct RefreshControl: View {
    let coordinateSpaceName: String
    let onRefresh: () -> Void
    
    @State private var refreshOffset: CGFloat = 0
    @State private var refreshThreshold: CGFloat = 80
    @State private var isRefreshing = false
    
    var body: some View {
        GeometryReader { geometry in
            if refreshOffset > refreshThreshold && !isRefreshing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(width: geometry.size.width, height: refreshThreshold)
                    .offset(y: -refreshThreshold)
                    .onAppear {
                        isRefreshing = true
                        onRefresh()
                        
                        // Reset after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isRefreshing = false
                        }
                    }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(min(refreshOffset / refreshThreshold, 1) * 1.5)
                    .frame(width: geometry.size.width, height: refreshThreshold)
                    .offset(y: -refreshThreshold)
                    .opacity(refreshOffset / refreshThreshold)
            }
        }
        .frame(height: 0)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .named(coordinateSpaceName)).origin.y
                    )
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            refreshOffset = -offset
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}