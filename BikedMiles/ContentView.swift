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
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(formatMiles(lastValue))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("miles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Trend indicator (centered)
                if lastValue > 0 {
                    VStack {
                        HStack(spacing: 2) {
                            getTrendIcon(lastValue: lastValue, currentValue: currentValue)
                            Text(formattedPercentChange)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    currentValue > lastValue ? .green :
                                    currentValue < lastValue ? .red : .gray
                                )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(currentValue > lastValue ? .systemGreen : currentValue < lastValue ? .systemRed : .systemGray5).opacity(0.2))
                    )
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                
                // Current period value (right aligned)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(formatMiles(currentValue))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("miles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func getTrendIcon(lastValue: Double, currentValue: Double) -> some View {
        if currentValue > lastValue {
            return Image(systemName: "arrow.up.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
        } else if currentValue < lastValue {
            return Image(systemName: "arrow.down.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
        } else {
            return Image(systemName: "equal.circle.fill")
                .foregroundColor(.gray)
                .font(.caption)
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
                HStack(spacing: 8) {
                    Text("🚴‍♀️")
                        .font(.largeTitle)
                    Text("Miles by Bike")
                        .font(.largeTitle)
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
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())
                .disabled(isLoading)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
                .padding(.trailing, 4)
            }
            .padding(.top, 25)
            .padding(.horizontal)
            .padding(.bottom, 10)

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
                        
                        VStack(spacing: 20) {
                            // Total Distance Card
                            totalDistanceCard()
                                .padding(.bottom, 5)
                            
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
                            .id(milesBiked["lastWeek"])
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["lastWeek"])
                            
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
                            .id(milesBiked["lastMonth"])
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["lastMonth"])
                            
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
                            .id(milesBiked["lastYear"])
                            .transition(.opacity)
                            .animation(.easeIn, value: milesBiked["lastYear"])
                        }
                        .padding()
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
    
    // Total distance card showing the current year's total
    private func totalDistanceCard() -> some View {
        let thisYearMiles = milesBiked["thisYear"] ?? 0
        
        return VStack(alignment: .center, spacing: 10) {
            Text("Total Distance \(dateRanges["thisYear"] ?? "")")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(numberFormatter.string(from: NSNumber(value: thisYearMiles)) ?? "0")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.trailing, 4)
                
                Text("miles")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(numberFormatter.string(from: NSNumber(value: milesBiked["thisWeek"] ?? 0)) ?? "0")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("mi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.1)))
                
                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(numberFormatter.string(from: NSNumber(value: milesBiked["thisMonth"] ?? 0)) ?? "0")
                            .font(.title3)
                            .fontWeight(.semibold)
                            
                        Text("mi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.1)))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
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