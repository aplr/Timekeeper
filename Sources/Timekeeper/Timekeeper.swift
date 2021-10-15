//
//  Timekeeper.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation

///
public class Timekeeper {

    public static let `default` = Timekeeper("default")
    
    /// The name of this timekeeper. Used for identifying in the logs.
    let label: String
    
    /// The lock used for synchronizing access to the underlying dict.
    var lock = pthread_rwlock_t()
    
    /// All stored measurements
    var measurements = [Measurement.Name: Measurement]()
    
    init(_ label: String) {
        self.label = label
        
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    public subscript(_ name: Measurement.Name) -> Measurement? {
        lockRead()
        defer { unlock() }
        return measurements[name]
    }

}

// MARK: - Measuring time

extension Timekeeper {
    
    @discardableResult
    public func start(_ name: Measurement.Name) -> Measurement {
        lockWrite()
        defer { unlock() }
        
        let measurement = Measurement(name)
        
        measurements[name] = measurement
        
        return measurement
    }
    
    @discardableResult
    public func lap(_ name: Measurement.Name) -> Measurement? {
        lockWrite()
        defer { unlock() }
        
        guard var measurement = measurements[name] else { return nil }
        
        measurement.laps.append(CFAbsoluteTimeGetCurrent())
        
        measurements[name] = measurement
        
        return measurement
    }
    
    @discardableResult
    public func stop(_ name: Measurement.Name) -> Measurement? {
        lockWrite()
        defer { unlock() }
        
        guard var measurement = measurements.removeValue(forKey: name) else { return nil }
        
        measurement.end = CFAbsoluteTimeGetCurrent()
        
        return measurement
    }
    
}

// MARK: - Convenience print functions

extension Timekeeper {
    
    public func lap(print name: Measurement.Name) {
        guard let measurement = lap(name) else {
            debugPrint("No measurement with name \(name) found.")
            return
        }
        
        print(measurement: measurement)
    }
    
    public func stop(print name: Measurement.Name) {
        guard let measurement = stop(name) else {
            debugPrint("No measurement with name \(name) found.")
            return
        }
        
        print(measurement: measurement)
    }
    
    private func print(measurement: Measurement) {
        var items: [String] = [
            "\(self)",
            "[\(measurement)] - ",
            "Total: \(measurement.totalDuration)s"
        ]
        
        if measurement.lapTimes.count > 1, let latestLap = measurement.lapTimes.last {
            items.insert("Lap #\(measurement.lapTimes.endIndex): \(latestLap)s - ", at: 2)
        }
        
        debugPrint(items)
    }
    
}

// MARK: - Stop measurements

extension Timekeeper {
    
    @discardableResult
    public func stopAll() -> [Measurement] {
        lockWrite()
        defer { unlock() }
        
        let time = CFAbsoluteTimeGetCurrent()
        
        let measurements = measurements.values.map({ measurement -> Measurement in
            var value = measurement
            value.end = time
            return value
        })
        
        self.measurements.removeAll()
        
        return measurements
    }
    
    public func stopAllPrint() {
        stopAll().forEach { print(measurement: $0) }
    }
    
    public func clear() {
        lockWrite()
        defer { unlock() }
        
        self.measurements.removeAll()
    }
    
}

// MARK: - Custom String Convertible Conformation

extension Timekeeper: CustomStringConvertible {
    
    public var description: String {
        "Timekeeper[\(label)]"
    }
    
}

// MARK: - Lock Management

extension Timekeeper {
    
    func lockWrite() {
        pthread_rwlock_wrlock(&lock)
    }
    
    func lockRead() {
        pthread_rwlock_rdlock(&lock)
    }
    
    func unlock() {
        pthread_rwlock_unlock(&lock)
    }
    
}
