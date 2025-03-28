//
//  DateHelpers.swift
//  BikedMiles
//
//  Created by Jeff Long on 3/13/24.
//

import Foundation

enum DateError: Error {
    case calculationError
}

extension Date {
    // Returns a formatted string for a date range
    func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate))-\(formatter.string(from: endDate))"
    }
    
    // Get week date range (Sunday to Saturday)
    func weekDateRange(startingFrom date: Date) -> (startDate: Date, endDate: Date, formatted: String)? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let weekStart = calendar.date(from: components) else { return nil }
        guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else { return nil }
        
        let formattedRange = formatDateRange(from: weekStart, to: weekEnd)
        return (weekStart, weekEnd, formattedRange)
    }
    
    // Get partial week date range (Sunday to specified weekday)
    func partialWeekDateRange(year: Int, month: Int, day: Int, endDay: Int) -> (startDate: Date, endDate: Date, formatted: String)? {
        let calendar = Calendar.current
        
        // Create a date from the components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        guard let date = calendar.date(from: dateComponents) else { return nil }
        
        // Get the start of the week (Sunday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let weekStart = calendar.date(from: components) else { return nil }
        
        // Calculate the number of days to add (0 for Sunday, 1 for Monday, etc.)
        let daysToAdd = min(endDay, 6) // Cap at 6 (Saturday)
        
        guard let partialWeekEnd = calendar.date(byAdding: .day, value: daysToAdd, to: weekStart) else { return nil }
        
        let formattedRange = formatDateRange(from: weekStart, to: partialWeekEnd)
        return (weekStart, partialWeekEnd, formattedRange)
    }
    
    // Get month date range
    func monthDateRange(year: Int, month: Int) -> (startDate: Date, endDate: Date, formatted: String)? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let monthStart = calendar.date(from: components),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart),
              let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth) else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let formattedMonth = formatter.string(from: monthStart)
        
        return (monthStart, monthEnd, formattedMonth)
    }
    
    // Get partial month date range (1st to current day)
    func partialMonthDateRange(year: Int, month: Int) -> (startDate: Date, endDate: Date, formatted: String)? {
        let calendar = Calendar.current
        let currentDate = self
        
        // Create the start date (1st of the month)
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = month
        startComponents.day = 1
        
        guard let monthStart = calendar.date(from: startComponents) else { return nil }
        
        // For the current month, end date is today
        // For other months, calculate what day of the month corresponds to today
        var endComponents = calendar.dateComponents([.day], from: currentDate)
        let endDay = endComponents.day ?? 1
        
        endComponents.year = year
        endComponents.month = month
        endComponents.day = min(endDay, calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 28)
        endComponents.hour = 23
        endComponents.minute = 59
        endComponents.second = 59
        
        guard let endDate = calendar.date(from: endComponents) else { return nil }
        
        let formattedRange = formatDateRange(from: monthStart, to: endDate)
        return (monthStart, endDate, formattedRange)
    }
    
    // Get year date range
    func yearDateRange(year: Int) -> (startDate: Date, endDate: Date, formatted: String)? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1
        
        guard let yearStart = calendar.date(from: components),
              let nextYear = calendar.date(byAdding: .year, value: 1, to: yearStart),
              let yearEnd = calendar.date(byAdding: .day, value: -1, to: nextYear) else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let formattedYear = formatter.string(from: yearStart)
        
        return (yearStart, yearEnd, formattedYear)
    }
    
    // Get partial year date range (Jan 1 to current month/day)
    func partialYearDateRange(year: Int) -> (startDate: Date, endDate: Date, formatted: String)? {
        let calendar = Calendar.current
        let currentDate = self
        
        // Create the start date (January 1)
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.day = 1
        
        guard let yearStart = calendar.date(from: startComponents) else { return nil }
        
        // Get current month and day (e.g., March 28)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentDay = calendar.component(.day, from: currentDate)
        
        // Create the equivalent date in the specified year (same month and day)
        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = currentMonth
        endComponents.day = currentDay
        endComponents.hour = 23
        endComponents.minute = 59
        endComponents.second = 59
        
        // Handle February 29 in non-leap years
        if currentMonth == 2 && currentDay == 29 {
            // Check if the specified year is a leap year
            var testComponents = DateComponents()
            testComponents.year = year
            testComponents.month = 2
            testComponents.day = 29
            
            if calendar.date(from: testComponents) == nil {
                endComponents.day = 28 // Use February 28 in non-leap years
            }
        }
        
        guard let endDate = calendar.date(from: endComponents) else { return nil }
        
        // Format the date range
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let endFormatted = formatter.string(from: endDate)
        return (yearStart, endDate, "Jan 1-\(endFormatted)")
    }
    
    func thisWeek() throws -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        // Get the start of the week containing this date
        // yearForWeekOfYear is crucial for handling dates near year boundaries
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let weekStartDate = calendar.date(from: components) else {
            throw DateError.calculationError
        }
        
        let year = calendar.component(.year, from: weekStartDate)
        let month = calendar.component(.month, from: weekStartDate)
        let day = calendar.component(.day, from: weekStartDate)
        return (year, month, day)
    }
    
    func lastWeek() throws -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        
        // First, find the start of the current week
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let weekStartDate = calendar.date(from: components) else {
            throw DateError.calculationError
        }
        
        // Subtract 7 days to get to the same day in the previous week
        guard let previousWeekSameDay = calendar.date(byAdding: .day, value: -7, to: weekStartDate) else {
            throw DateError.calculationError
        }
        
        // Get the start of that week
        let prevWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: previousWeekSameDay)
        guard let prevWeekStartDate = calendar.date(from: prevWeekComponents) else {
            throw DateError.calculationError
        }
        
        let year = calendar.component(.year, from: prevWeekStartDate)
        let month = calendar.component(.month, from: prevWeekStartDate)
        let day = calendar.component(.day, from: prevWeekStartDate)
        return (year, month, day)
    }
    
    func thisMonth() throws -> (year: Int, month: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        return (year, month)
    }

    func lastMonth() throws -> (year: Int, month: Int) {
        let calendar = Calendar.current
        guard let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: self) else {
            throw DateError.calculationError
        }
        let year = calendar.component(.year, from: lastMonthDate)
        let month = calendar.component(.month, from: lastMonthDate)
        return (year, month)
    }

    func thisYear() -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }

    func lastYear() throws -> Int {
        let calendar = Calendar.current
        guard let lastYearDate = calendar.date(byAdding: .year, value: -1, to: self) else {
            throw DateError.calculationError
        }
        return calendar.component(.year, from: lastYearDate)
    }
    
    // Get the current day of the month
    func currentDayOfMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
}
