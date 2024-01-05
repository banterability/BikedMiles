//
//  HealthKitManager.swift
//  Hello World
//
//  Created by Kellan Elliott-McCrea on 10/28/23.
//

import HealthKit

class HealthKitManager {
    private var healthStore: HKHealthStore?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            print("initialized healthstore")
        } else {
            print("init failed, no health data available")
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = self.healthStore else {
            print("requestAuthorization failed to get HealthStore")
            completion(false, nil)
            return
        }
        
        let cyclingDistanceType = HKObjectType.quantityType(forIdentifier: .distanceCycling)!
        
        healthStore.requestAuthorization(toShare: [],
                read: [cyclingDistanceType]) { success, error in
                    completion(success, error)
                }

    }
 
    func fetchMilesBiked(year: Int, completion: @escaping (Double?, Error?) -> Void) {
        print(HKHealthStore.isHealthDataAvailable())
        
        let quantityType = HKQuantityTypeIdentifier.distanceCycling

        // Check if HealthKit is available and cycling distance data is accessible
        guard HKHealthStore.isHealthDataAvailable(),
              let cyclingDistanceType = HKObjectType.quantityType(forIdentifier: quantityType) else {
            completion(nil, nil)
            return
        }
        
        let calendar = Calendar.current
        
        let firstDayOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let lastDayOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!

        print(firstDayOfYear)
        print(lastDayOfYear)
        
        // Create a predicate for the date range of last year
        let predicate = HKQuery.predicateForSamples(withStart: firstDayOfYear, end: lastDayOfYear, options: .strictStartDate)

        
        
        // Create a statistics query
        let query = HKStatisticsQuery(quantityType: cyclingDistanceType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, result, error in
            guard let sum = result?.sumQuantity() else {
                completion(nil, error)
                return
            }

            // Change the unit to miles or meters based on your preference
            completion(sum.doubleValue(for: HKUnit.mile()), nil)
        }
        
        // Execute the query
        let healthStore = HKHealthStore()
        healthStore.execute(query)
    }
    
    func milesBikedThisYear(completion: @escaping (Double?, Error?) -> Void) {
        // Get the current date and calendar
        let now = Date()
        let calendar = Calendar.current

        // Calculate the first and last day of the current year
        let currentYear = calendar.component(.year, from: now)
        fetchMilesBiked(year: currentYear, completion: completion)
    }
    
    func milesBikedLastYear(completion: @escaping (Double?, Error?) -> Void) {
        // Get the current date and calendar
        let now = Date()
        let calendar = Calendar.current

        // Calculate the first and last day of the last year
        let lastYear = (calendar.component(.year, from: now) - 1)
        fetchMilesBiked(year: lastYear, completion: completion)
    }
}
