//
//  HealthKitManager.swift
//  WeighWise
//
//  Created by 625098 on 1/9/24.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    let healthStore = HKHealthStore()
    
    func getWeight(completion: @escaping (Double?, Error?) -> Void) {
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: nil) { ( query, results, error) in
            guard let sample = results?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            
            let weightValue = sample.quantity.doubleValue(for: HKUnit.pound())
            completion(weightValue, nil)
        }
        
        healthStore.execute(query)
    }
    
    func fetchWeightDataToday(completion: @escaping (Double?) -> Void) {
        let healthStore = HKHealthStore()

        // Check if weight data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil)
            return
        }

        // Define the weight type
        guard let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil)
            return
        }

        // Define the query for today's weight data
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: Date(), options: .strictStartDate)
        let query = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], let weight = samples.first?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)) else {
                // Handle the case where no data is available
                completion(nil)
                return
            }

            // Return the weight data
            completion(weight)
        }

        // Execute the query
        healthStore.execute(query)
    }
    
    func fetchAllHealthData(completion: @escaping ([String: Any]?) -> Void) {
        let healthStore = HKHealthStore()

        // Check if health data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil)
            return
        }

        // Define types for all available health data
        let healthDataTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            // Add more types as needed
        ]

        // Request authorization for all health data types
//        healthStore.requestAuthorization(toShare: nil, read: healthDataTypes) { (success, error) in
//            guard success else {
//                completion(nil)
//                return
//            }

            // Define a query for all health data
//            let query = HKSampleQuery(sampleType: HKObjectType.quantityType(forIdentifier: .bodyMass)!, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
//                guard let samples = results else {
//                    completion(nil)
//                    return
//                }

                // Create a dictionary to store health data
//                var healthData: [String: Any] = [:]

                // Loop through samples and add data to the dictionary
//                for sample in samples {
//                   print("\(sample)")
//                }

                // Return the collected health data
//                completion(healthData)
//            }

            // Execute the query
//            healthStore.execute(query)
    }
    
    func startObservingWeightChanges() {
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            
            let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
            
            let observerQuery = HKObserverQuery(sampleType: weightType, predicate: nil) { (_, completionHandler, _ ) in
                print("Health data changed.")
                print("\(weightType)")
                completionHandler()
            }
            healthStore.execute(observerQuery)
        }
    }
}
