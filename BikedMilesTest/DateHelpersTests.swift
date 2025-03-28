import XCTest
@testable import BikedMiles

final class DateHelpersTests: XCTestCase {
    let calendar = Calendar.current
    
    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour)
        return calendar.date(from: components)!
    }
    
    func test_thisWeekInJanuary() throws {
        let testDate = makeDate(year: 2025, month: 1, day: 15)
        
        let result = try testDate.thisWeek()
        
        XCTAssertEqual(result.year, 2025)
        XCTAssertEqual(result.month, 1)
        XCTAssertEqual(result.day, 12)
    }
    
    func test_sundayInMarch() throws {
        let testDate = makeDate(year: 2025, month: 3, day: 9)
        
        let thisWeek = try testDate.thisWeek()
        XCTAssertEqual(thisWeek.year, 2025)
        XCTAssertEqual(thisWeek.month, 3)
        XCTAssertEqual(thisWeek.day, 9) //same day, since it's already sunday
        
        let lastWeek = try testDate.lastWeek()
        XCTAssertEqual(lastWeek.year, 2025)
        XCTAssertEqual(lastWeek.month, 3)
        XCTAssertEqual(lastWeek.day, 2)
    }
    
    func test_weekCrossingJanuaryDecember() throws {
        let testDate = makeDate(year: 2025, month: 1, day: 2)
        
        let thisWeek = try testDate.thisWeek()
        XCTAssertEqual(thisWeek.year, 2024)
        XCTAssertEqual(thisWeek.month, 12)
        XCTAssertEqual(thisWeek.day, 29)
        
        let lastWeek = try testDate.lastWeek()
        XCTAssertEqual(lastWeek.year, 2024)
        XCTAssertEqual(lastWeek.month, 12)
        XCTAssertEqual(lastWeek.day, 22)
    }
    
    func test_thisMonthFebruary() throws {
        let testDate = makeDate(year: 2025, month: 2, day: 15)
        
        let result = try testDate.thisMonth()
        
        XCTAssertEqual(result.year, 2025)
        XCTAssertEqual(result.month, 2)
    }
    
    func test_lastMonthFromFebruary() throws {
        let testDate = makeDate(year: 2025, month: 2, day: 1)
        
        let result = try testDate.lastMonth()
        
        XCTAssertEqual(result.year, 2025)
        XCTAssertEqual(result.month, 1)
    }
    
    func test_lastMonthFromJanuary() throws {
        let testDate = makeDate(year: 2025, month: 1, day: 15)
        
        let result = try testDate.lastMonth()
        
        XCTAssertEqual(result.year, 2024)
        XCTAssertEqual(result.month, 12)
    }
    
    func test_thisYearJanuary() {
        let testDate = makeDate(year: 2025, month: 1, day: 1)
        
        let result = testDate.thisYear()
        
        XCTAssertEqual(result, 2025)
    }
    
    func test_lastYearFromJanuary() throws {
        let testDate = makeDate(year: 2025, month: 1, day: 1)
        
        let result = try testDate.lastYear()
        
        XCTAssertEqual(result, 2024)
    }
    
    func test_weekBoundaryAtEndOfJanuary() throws {
        // January 31st, 2025 (Friday)
        let testDate = makeDate(year: 2025, month: 1, day: 31)
        
        let thisWeekResult = try testDate.thisWeek()
        let lastWeekResult = try testDate.lastWeek()
        
        XCTAssertEqual(thisWeekResult.year, 2025)
        XCTAssertEqual(thisWeekResult.month, 1)
        
        XCTAssertEqual(lastWeekResult.year, 2025)
        XCTAssertEqual(lastWeekResult.month, 1)
    }
    
    func test_weekBoundaryAtStartOfFebruary() throws {
        // February 1st, 2025 (Saturday)
        let testDate = makeDate(year: 2025, month: 2, day: 1)
        
        let thisWeekResult = try testDate.thisWeek()
        let lastWeekResult = try testDate.lastWeek()
        
        XCTAssertEqual(thisWeekResult.year, 2025)
        XCTAssertEqual(thisWeekResult.month, 1) // Week starts in January
        
        XCTAssertEqual(lastWeekResult.year, 2025)
        XCTAssertEqual(lastWeekResult.month, 1)
    }
    
    func test_formatDateRange() {
        let date = Date()
        let startDate = makeDate(year: 2025, month: 3, day: 15)
        let endDate = makeDate(year: 2025, month: 3, day: 21)
        
        let formattedRange = date.formatDateRange(from: startDate, to: endDate)
        
        // Our DateHelpers implementation uses "MMM d-MMM d" format
        XCTAssertEqual(formattedRange, "Mar 15-Mar 21")
    }
    
    func test_weekDateRange() {
        // Sunday, March 9, 2025
        let testDate = makeDate(year: 2025, month: 3, day: 9)
        
        guard let weekRange = testDate.weekDateRange(startingFrom: testDate) else {
            XCTFail("Failed to get week date range")
            return
        }
        
        // The week should start on Sunday (Mar 9) and end on Saturday (Mar 15)
        let expectedStartDay = 9
        let expectedEndDay = 15
        
        let startDay = calendar.component(.day, from: weekRange.startDate)
        let endDay = calendar.component(.day, from: weekRange.endDate)
        
        XCTAssertEqual(startDay, expectedStartDay)
        XCTAssertEqual(endDay, expectedEndDay)
        XCTAssertEqual(weekRange.formatted, "Mar 9-Mar 15")
    }
    
    func test_weekDateRangeCrossingMonths() {
        // Saturday, January 31, 2025
        let testDate = makeDate(year: 2025, month: 1, day: 31)
        
        // Find the start of this week (Sunday, Jan 26)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: testDate)
        guard let weekStart = calendar.date(from: components) else {
            XCTFail("Failed to get week start")
            return
        }
        
        guard let weekRange = testDate.weekDateRange(startingFrom: weekStart) else {
            XCTFail("Failed to get week date range")
            return
        }
        
        // Week should be Jan 26 - Feb 1
        let startMonth = calendar.component(.month, from: weekRange.startDate)
        let endMonth = calendar.component(.month, from: weekRange.endDate)
        
        XCTAssertEqual(startMonth, 1) // January
        XCTAssertEqual(endMonth, 2)   // February
        XCTAssertEqual(weekRange.formatted, "Jan 26-Feb 1")
    }
    
    func test_monthDateRange() {
        // February 15, 2025
        let testDate = makeDate(year: 2025, month: 2, day: 15)
        
        guard let monthRange = testDate.monthDateRange(year: 2025, month: 2) else {
            XCTFail("Failed to get month date range")
            return
        }
        
        // February 2025 should start on day 1 and end on day 28 (not a leap year)
        let startDay = calendar.component(.day, from: monthRange.startDate)
        let endDay = calendar.component(.day, from: monthRange.endDate)
        
        XCTAssertEqual(startDay, 1)
        XCTAssertEqual(endDay, 28)
        XCTAssertEqual(monthRange.formatted, "February 2025")
    }
    
    func test_monthDateRangeForLeapYear() {
        // February in a leap year (2024)
        let testDate = makeDate(year: 2024, month: 2, day: 15)
        
        guard let monthRange = testDate.monthDateRange(year: 2024, month: 2) else {
            XCTFail("Failed to get month date range")
            return
        }
        
        // February 2024 should start on day 1 and end on day 29 (leap year)
        let endDay = calendar.component(.day, from: monthRange.endDate)
        
        XCTAssertEqual(endDay, 29)
        XCTAssertEqual(monthRange.formatted, "February 2024")
    }
    
    func test_yearDateRange() {
        // 2025
        let testDate = makeDate(year: 2025, month: 6, day: 15)
        
        guard let yearRange = testDate.yearDateRange(year: 2025) else {
            XCTFail("Failed to get year date range")
            return
        }
        
        // 2025 should start on Jan 1 and end on Dec 31
        let startMonth = calendar.component(.month, from: yearRange.startDate)
        let startDay = calendar.component(.day, from: yearRange.startDate)
        let endMonth = calendar.component(.month, from: yearRange.endDate)
        let endDay = calendar.component(.day, from: yearRange.endDate)
        
        XCTAssertEqual(startMonth, 1)
        XCTAssertEqual(startDay, 1)
        XCTAssertEqual(endMonth, 12)
        XCTAssertEqual(endDay, 31)
        XCTAssertEqual(yearRange.formatted, "2025")
    }
}
