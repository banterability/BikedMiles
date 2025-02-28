import XCTest
@testable import BikedMiles

final class DateHelpersTests: XCTestCase {
    let calendar = Calendar.current
    
    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour)
        return calendar.date(from: components)!
    }
    
    func test_thisWeekInJanuary() {
        // January 15th, 2025
        let testDate = makeDate(year: 2025, month: 1, day: 15)
        
        let result = try? testDate.thisWeek()
        
        XCTAssertEqual(result?.year, 2025)
        XCTAssertEqual(result?.month, 1)
    }
    
    func test_lastWeekCrossingJanuaryDecember() throws {
        // January 2nd, 2025 (Wednesday)
        let testDate = makeDate(year: 2025, month: 1, day: 2)
        
        let result = try testDate.lastWeek()
        
        XCTAssertEqual(result.year, 2024)
        XCTAssertEqual(result.month, 12)
        XCTAssertEqual(result.day, 29)
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
}
