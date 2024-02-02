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
//        guard let footDistanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
//            let error = NSError(domain: "HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Walking/Running Distance Type not available"])
//            completion(false, error)
//            return
//        }

//        healthStore.requestAuthorization(toShare: [], read: [cyclingDistanceType, footDistanceType]) { success, error in
        healthStore.requestAuthorization(toShare: [], read: [cyclingDistanceType]) { success, error in
            completion(success, error)
        }
    }

    func fetchMiles(for activityType: HKQuantityTypeIdentifier, year: Int, completion: @escaping (Double?, Error?) -> Void) {
        guard let healthStore = self.healthStore,
              let activityDistanceType = HKObjectType.quantityType(forIdentifier: activityType) else {
            let error = NSError(domain: "HealthKitManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot access HealthKit data"])
            completion(nil, error)
            return
        }

        let firstDayOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let lastDayOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!

        let predicate = HKQuery.predicateForSamples(withStart: firstDayOfYear, end: lastDayOfYear, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: activityDistanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let sum = result?.sumQuantity() else {
                completion(nil, error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.mile()), nil)
        }
        
        healthStore.execute(query)
    }

    // Usage
    func fetchMilesByBike(year: Int, completion: @escaping (Double?, Error?) -> Void) {
        fetchMiles(for: .distanceCycling, year: year, completion: completion)
    }

//    func fetchMilesByFoot(year: Int, completion: @escaping (Double?, Error?) -> Void) {
//        fetchMiles(for: .distanceWalkingRunning, year: year, completion: completion)
//    }

}
