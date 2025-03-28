//
//  ContentView.swift

import SwiftUI

struct ThreeWayStatCard: View {
    let lastPeriod: String
    let equivalentPeriod: String
    let currentPeriod: String
    let lastValue: Double
    let equivalentValue: Double
    let currentValue: Double
    let formatter: NumberFormatter
    let lastDateRange: String
    let equivalentDateRange: String
    let currentDateRange: String
    
    private var percentChangeFromLast: Double {
        guard lastValue > 0 else { return Double.infinity }
        return ((currentValue - lastValue) / lastValue) * 100
    }
    
    private var percentChangeFromEquivalent: Double {
        guard equivalentValue > 0 else { return Double.infinity }
        return ((currentValue - equivalentValue) / equivalentValue) * 100
    }
    
    private func formatPercentChange(_ change: Double) -> String {
        if change.isInfinite {
            return "∞"
        }
        let absChange = abs(change)
        let formattedValue = String(format: "%.0f", absChange)
        return "\(formattedValue)%"
    }
    
    private func formatMiles(_ value: Double) -> String {
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Current period value - larger
            HStack(alignment: .center) {
                // Title with date range
                VStack(alignment: .leading, spacing: 0) {
                    Text(currentPeriod)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(currentDateRange)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Value
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(formatMiles(currentValue))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("mi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 2)
            .padding(.horizontal, 2)
            
            Divider()
                .padding(.vertical, 6)
            
            // Last period equivalent value
            HStack(alignment: .center, spacing: 8) {
                // Title with date range
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(lastPeriod) (So Far)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(equivalentDateRange)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Trend indicator
                if currentValue > 0 {
                    HStack(spacing: 2) {
                        getTrendIcon(baseValue: equivalentValue, comparedValue: currentValue)
                        Text(formatPercentChange(percentChangeFromEquivalent))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(currentValue > equivalentValue ? Color.green : currentValue < equivalentValue ? Color.red : Color.gray)
                    )
                }
                
                // Value
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(formatMiles(equivalentValue))")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("mi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 2)
            
            // Last period total value
            HStack(alignment: .center, spacing: 8) {
                // Title with date range
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(lastPeriod)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(lastDateRange)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Trend indicator
                if currentValue > 0 {
                    HStack(spacing: 2) {
                        getTrendIcon(baseValue: lastValue, comparedValue: currentValue)
                        Text(formatPercentChange(percentChangeFromLast))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(currentValue > lastValue ? Color.green : currentValue < lastValue ? Color.red : Color.gray)
                    )
                }
                
                // Value
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(formatMiles(lastValue))")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("mi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
    
    private func getTrendIcon(baseValue: Double, comparedValue: Double) -> some View {
        if baseValue == 0 && comparedValue > 0 {
            return Image(systemName: "arrow.up.circle.fill")
                .foregroundColor(.white)
                .font(.subheadline)
        } else if comparedValue > baseValue {
            return Image(systemName: "arrow.up.circle.fill")
                .foregroundColor(.white)
                .font(.subheadline)
        } else if comparedValue < baseValue {
            return Image(systemName: "arrow.down.circle.fill")
                .foregroundColor(.white)
                .font(.subheadline)
        } else {
            return Image(systemName: "equal.circle.fill")
                .foregroundColor(.white)
                .font(.subheadline)
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
        // Wrap the entire view in withAnimation for state changes
        VStack {
            HStack {
                HStack(spacing: 6) {
                    Text("🚴‍♀️")
                        .font(.title2)
                    Text("Miles Biked")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.leading, 4)
                
                Spacer()
                
                // Refresh button with spinner animation
                Button(action: {
                    fetchMilesData()
                }) {
                    if isLoading {
                        SpinnerView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())
                .disabled(isLoading)
                .padding(8)
                .padding(.trailing, 4)
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .padding(.bottom, 0)

            if isAuthorized {
                if isLoading && milesBiked.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        SpinnerView()
                            .frame(width: 50, height: 50)
                        
                        Text("Loading your cycling data...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .transition(.opacity)
                    Spacer()
                } else {
                    ScrollView {
                        // Pull to refresh
                        RefreshControl(coordinateSpaceName: "pullToRefresh", onRefresh: fetchMilesData)
                            .padding(.top, -50)
                        
                        VStack(spacing: 12) {
                            // Weekly Stats with Three-Way Comparison
                            ThreeWayStatCard(
                                lastPeriod: "Last Week",
                                equivalentPeriod: "This Time Last Week",
                                currentPeriod: "This Week",
                                lastValue: milesBiked["lastWeekFull"] ?? 0,
                                equivalentValue: milesBiked["lastWeekPartial"] ?? 0,
                                currentValue: milesBiked["thisWeek"] ?? 0,
                                formatter: numberFormatter,
                                lastDateRange: dateRanges["lastWeekFull"] ?? "",
                                equivalentDateRange: dateRanges["lastWeekPartial"] ?? "",
                                currentDateRange: dateRanges["thisWeek"] ?? ""
                            )
                            .id(milesBiked["thisWeek"])
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["thisWeek"])
                            
                            // Monthly Stats with Three-Way Comparison
                            ThreeWayStatCard(
                                lastPeriod: "Last Month",
                                equivalentPeriod: "This Time Last Month",
                                currentPeriod: "This Month",
                                lastValue: milesBiked["lastMonthFull"] ?? 0,
                                equivalentValue: milesBiked["lastMonthPartial"] ?? 0,
                                currentValue: milesBiked["thisMonth"] ?? 0,
                                formatter: numberFormatter,
                                lastDateRange: dateRanges["lastMonthFull"] ?? "",
                                equivalentDateRange: dateRanges["lastMonthPartial"] ?? "",
                                currentDateRange: dateRanges["thisMonth"] ?? ""
                            )
                            .id(milesBiked["thisMonth"])
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["thisMonth"])
                            
                            // Yearly Stats with Three-Way Comparison
                            ThreeWayStatCard(
                                lastPeriod: "Last Year",
                                equivalentPeriod: "This Time Last Year",
                                currentPeriod: "This Year",
                                lastValue: milesBiked["lastYearFull"] ?? 0,
                                equivalentValue: milesBiked["lastYearPartial"] ?? 0,
                                currentValue: milesBiked["thisYear"] ?? 0,
                                formatter: numberFormatter,
                                lastDateRange: dateRanges["lastYearFull"] ?? "",
                                equivalentDateRange: dateRanges["lastYearPartial"] ?? "",
                                currentDateRange: dateRanges["thisYear"] ?? ""
                            )
                            .id(milesBiked["thisYear"])
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["thisYear"])
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .coordinateSpace(name: "pullToRefresh")
                }
            } else {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "bolt.slash.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Access Required")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("BikedMiles needs permission to access your Health data")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            Text("Open the Settings app on your device")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            Text("Tap Privacy & Security → Health")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(.blue)
                            Text("Find and tap BikedMiles in the list")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "4.circle.fill")
                                .foregroundColor(.blue)
                            Text("Enable access to your cycling distance data")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    Button(action: {
                        fetchMilesData()
                    }) {
                        Text("Try Again")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 12)
                }
                .padding()
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
            
            // Get the current day of month and day of year for equivalent comparisons
            let currentDayOfMonth = currentDate.currentDayOfMonth()
            let calendar = Calendar.current
            let currentDayOfYear = calendar.ordinality(of: .day, in: .year, for: currentDate) ?? 1
            let currentDayOfWeek = calendar.component(.weekday, from: currentDate) - 1 // 0 = Sunday, 6 = Saturday
            
            // Current week - full week range
            if let currentWeekRange = currentDate.weekDateRange(startingFrom: createDate(year: currentWeek.year, month: currentWeek.month, day: currentWeek.day)) {
                self.dateRanges["thisWeekFull"] = currentWeekRange.formatted
            }
            
            // Current week - partial range (Sunday to current day)
            if let currentWeekPartialRange = currentDate.partialWeekDateRange(year: currentWeek.year, month: currentWeek.month, day: currentWeek.day, endDay: currentDayOfWeek) {
                self.dateRanges["thisWeek"] = currentWeekPartialRange.formatted
            }
            
            // Last week - full week range
            if let lastWeekRange = currentDate.weekDateRange(startingFrom: createDate(year: lastWeek.year, month: lastWeek.month, day: lastWeek.day)) {
                self.dateRanges["lastWeekFull"] = lastWeekRange.formatted
            }
            
            // Last week - equivalent days range (partial, same days as current week)
            if let lastWeekPartialRange = currentDate.partialWeekDateRange(year: lastWeek.year, month: lastWeek.month, day: lastWeek.day, endDay: currentDayOfWeek) {
                self.dateRanges["lastWeekPartial"] = lastWeekPartialRange.formatted
            }
            
            // Current month - full month range
            if let currentMonthRange = currentDate.monthDateRange(year: currentMonthYear, month: currentMonth) {
                self.dateRanges["thisMonthFull"] = currentMonthRange.formatted
            }
            
            // Current month - partial range (1st to current day)
            if let currentMonthPartialRange = currentDate.partialMonthDateRange(year: currentMonthYear, month: currentMonth) {
                self.dateRanges["thisMonth"] = currentMonthPartialRange.formatted
            }
            
            // Last month - full month range
            if let lastMonthRange = currentDate.monthDateRange(year: lastMonthYear, month: lastMonth) {
                self.dateRanges["lastMonthFull"] = lastMonthRange.formatted
            }
            
            // Last month - equivalent days range (partial, same days as current month)
            if let lastMonthPartialRange = currentDate.partialMonthDateRange(year: lastMonthYear, month: lastMonth) {
                self.dateRanges["lastMonthPartial"] = lastMonthPartialRange.formatted
            }
            
            // Current year - full year range
            if let currentYearRange = currentDate.yearDateRange(year: currentYear) {
                self.dateRanges["thisYearFull"] = currentYearRange.formatted
            }
            
            // Current year - partial range (Jan 1 to current day)
            if let currentYearPartialRange = currentDate.partialYearDateRange(year: currentYear) {
                self.dateRanges["thisYear"] = currentYearPartialRange.formatted
            }
            
            // Last year - full year range
            if let lastYearRange = currentDate.yearDateRange(year: previousYear) {
                self.dateRanges["lastYearFull"] = lastYearRange.formatted
            }
            
            // Last year - equivalent days range (Jan 1 to same day of year)
            if let lastYearPartialRange = currentDate.partialYearDateRange(year: previousYear) {
                self.dateRanges["lastYearPartial"] = lastYearPartialRange.formatted
            }
            
            // Create a dispatch group to track when all fetch operations complete
            let group = DispatchGroup()
            
            // Fetch full week data for last week
            group.enter()
            healthKitManager.fetchMilesByBikeForWeek(
                year: lastWeek.year,
                month: lastWeek.month,
                day: lastWeek.day
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastWeekFull"] = miles
                    group.leave()
                }
            }
            
            // Fetch partial week data for last week (equivalent period)
            group.enter()
            healthKitManager.fetchMilesByBikeForPartialWeek(
                year: lastWeek.year,
                month: lastWeek.month,
                day: lastWeek.day,
                currentWeekDay: currentDayOfWeek
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastWeekPartial"] = miles
                    group.leave()
                }
            }
            
            // Fetch current partial week data
            group.enter()
            healthKitManager.fetchMilesByBikeForPartialWeek(
                year: currentWeek.year,
                month: currentWeek.month,
                day: currentWeek.day,
                currentWeekDay: currentDayOfWeek
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["thisWeek"] = miles
                    group.leave()
                }
            }
            
            // Fetch full month data for last month
            group.enter()
            healthKitManager.fetchMilesByBikeForMonth(
                year: lastMonthYear,
                month: lastMonth
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastMonthFull"] = miles
                    group.leave()
                }
            }
            
            // Fetch partial month data for last month (equivalent period)
            group.enter()
            healthKitManager.fetchMilesByBikeForPartialMonth(
                year: lastMonthYear,
                month: lastMonth,
                day: currentDayOfMonth
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastMonthPartial"] = miles
                    group.leave()
                }
            }
            
            // Fetch current partial month data
            group.enter()
            healthKitManager.fetchMilesByBikeForPartialMonth(
                year: currentMonthYear,
                month: currentMonth,
                day: currentDayOfMonth
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["thisMonth"] = miles
                    group.leave()
                }
            }
            
            // Fetch full year data for last year
            group.enter()
            healthKitManager.fetchMilesByBikeForYear(
                year: previousYear
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastYearFull"] = miles
                    group.leave()
                }
            }
            
            // Fetch partial year data for last year (equivalent period)
            group.enter()
            healthKitManager.fetchMilesByBikeForPartialYear(
                year: previousYear,
                dayOfYear: currentDayOfYear
            ) { miles, error in
                DispatchQueue.main.async {
                    self.milesBiked["lastYearPartial"] = miles
                    group.leave()
                }
            }
            
            // Fetch current partial year data
            group.enter()
            healthKitManager.fetchMilesByBikeForPartialYear(
                year: currentYear,
                dayOfYear: currentDayOfYear
            ) { miles, error in
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

// Custom spinner view with continuous rotation animation
struct SpinnerView: View {
    @State private var isAnimating = false
    @State private var trimEnd: CGFloat = 0.75
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.blue.opacity(0.2), lineWidth: 3)
            
            // Animated arc
            Circle()
                .trim(from: 0.0, to: trimEnd)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
            
            // Pulse the arc length for a more dynamic effect
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                trimEnd = 0.5
            }
        }
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
