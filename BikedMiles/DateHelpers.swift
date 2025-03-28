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
}
