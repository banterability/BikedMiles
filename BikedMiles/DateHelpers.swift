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
    func thisWeek()  -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current;
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let weekStartDate = calendar.date(from: components)!
        let year = calendar.component(.year, from: weekStartDate)
        let month = calendar.component(.month, from :weekStartDate)
        let day = calendar.component(.day, from: weekStartDate)
        return (year, month, day)
    }
    
    func lastWeek() throws -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current;
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let weekStartDate = calendar.date(from: components)!
        guard let lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: weekStartDate) else {
            throw DateError.calculationError
        }
        let year = calendar.component(.year, from: lastWeekDate)
        let month = calendar.component(.month, from: lastWeekDate)
        let day = calendar.component(.day, from: lastWeekDate)
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
