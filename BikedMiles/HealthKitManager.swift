//
//  HealthKitManager.swift
//  Hello World
//
//  Created by Kellan Elliott-McCrea on 10/28/23.
//

import HealthKit

class HealthKitManager {
    private var healthStore: HKHealthStore?
    private let calendar = Calendar.current

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            print("Initialized HealthStore")
        } else {
            print("Init failed, no health data available")
        }
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = self.healthStore else {
            let error = NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthStore not available"])
            completion(false, error)
            return
        }
        
        guard let cyclingDistanceType = HKObjectType.quantityType(forIdentifier: .distanceCycling) else {
            let error = NSError(domain: "HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cycling Distance Type not available"])
            completion(false, error)
            return
        }

        healthStore.requestAuthorization(toShare: [], read: [cyclingDistanceType]) { success, error in
            completion(success, error)
        }
    }

    func fetchMilesForRange(for activityType: HKQuantityTypeIdentifier, startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let healthStore = self.healthStore,
              let activityDistanceType = HKObjectType.quantityType(forIdentifier: activityType) else {
            let error = NSError(domain: "HealthKitManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot access HealthKit data"])
            completion(nil, error)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: activityDistanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let sum = result?.sumQuantity() else {
                completion(nil, error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.mile()), nil)
        }
        
        healthStore.execute(query)

    }
    func fetchMilesForWeek(for activityType: HKQuantityTypeIdentifier, year: Int, month: Int, day: Int, completion: @escaping (Double?, Error?) -> Void){
        let today = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let lastSecondOfWeek = calendar.date(byAdding: DateComponents(day: 6, hour: 23, minute: 59, second: 59), to: firstDayOfWeek)!

        fetchMilesForRange(for: activityType, startDate: firstDayOfWeek, endDate: lastSecondOfWeek, completion: completion)
    }
    
    func fetchMilesForMonth(for activityType: HKQuantityTypeIdentifier, year: Int, month: Int, completion: @escaping (Double?, Error?) -> Void){
        let dateComponents = DateComponents(year: year, month: month)
        let firstDayOfMonth = calendar.date(from: dateComponents)!
        let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)!
        let lastSecondOfMonth = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDayOfMonth)!

        fetchMilesForRange(for: activityType, startDate: firstDayOfMonth, endDate: lastSecondOfMonth, completion: completion)
    }

    func fetchMilesForYear(for activityType: HKQuantityTypeIdentifier, year: Int, completion: @escaping (Double?, Error?) -> Void) {
        let firstDayOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let lastDayOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        let lastSecondOfYear = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDayOfYear)!

        fetchMilesForRange(for: activityType, startDate: firstDayOfYear, endDate: lastSecondOfYear, completion:completion)
    }

    func fetchMilesByBikeForYear(year: Int, completion: @escaping (Double?, Error?) -> Void) {
        fetchMilesForYear(for: .distanceCycling, year: year, completion: completion)
    }
    func fetchMilesByBikeForMonth(year: Int, month: Int, completion: @escaping (Double?, Error?) -> Void) {
        fetchMilesForMonth(for: .distanceCycling, year: year, month:month, completion: completion)
    }
    func fetchMilesByBikeForWeek(year: Int, month: Int, day: Int, completion: @escaping (Double?, Error?) -> Void) {
        fetchMilesForWeek(for: .distanceCycling, year: year, month:month, day: day, completion: completion)
    }
}
