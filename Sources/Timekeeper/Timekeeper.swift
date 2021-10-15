//
//  Timekeeper.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation

/// A time measurement class allowing to keep track of the duration of code.
public class Timekeeper {
    
    /// The default timekeeper instance
    public static let `default` = Timekeeper("default")
    
    /// The name of this timekeeper. Used for identifying in the logs.
    let label: String
    
    /// The lock used for synchronizing access to the underlying dict.
    var lock = pthread_rwlock_t()
    
    /// The dictionary storing all current measurements
    var measurements = [Measurement.Name: Measurement]()
    
    /// Creates a new Timekeeper instance with the specified label.
    ///
    /// - Parameter label: The name of the timekeeper instance
    init(_ label: String) {
        self.label = label
        
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    /// Accesses the measurement with the specified name.
    ///
    /// - Parameter name: The name of the measurement
    public subscript(_ name: Measurement.Name) -> Measurement? {
        lockRead()
        defer { unlock() }
        return measurements[name]
    }

}

// MARK: - Measuring time

extension Timekeeper {
    
    /// Starts a new measurement, setting the start time to the current
    /// system absolute time using `CFAbsoluteTimeGetCurrent`.
    /// If there was a measurement with this name before, it is replaced
    /// by a new one.
    ///
    /// - Parameter name: The name of the measurement
    /// - Returns: The measurement
    @discardableResult
    public func start(_ name: Measurement.Name) -> Measurement {
        lockWrite()
        defer { unlock() }
        
        let measurement = Measurement(name)
        
        measurements[name] = measurement
        
        return measurement
    }
    
    /// Adds a lap to the measurement, if one exists with the specified name.
    /// Otherwise, the function will just return nil.
    ///
    /// - Parameter name: The name of the measurement
    /// - Returns: The measurement
    @discardableResult
    public func lap(_ name: Measurement.Name) -> Measurement? {
        lockWrite()
        defer { unlock() }
        
        guard var measurement = measurements[name] else { return nil }
        
        measurement.laps.append(CFAbsoluteTimeGetCurrent())
        
        measurements[name] = measurement
        
        return measurement
    }
    
    /// Sets the end time on the measurement if one exists with the specified name,
    /// removes it from the timekeeper instance and returns it.
    ///
    /// - Parameter name: The name of the measurement
    /// - Returns: The meausrement
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
    
    /// Adds a lap to the measurement and prints it, if there exists one with the specified name.
    ///
    /// - Parameter name: The name of the measurement
    public func lap(print name: Measurement.Name) {
        guard let measurement = lap(name) else {
            debugPrint("No measurement with name \(name) found.")
            return
        }
        
        print(measurement: measurement)
    }
    
    /// Sets the end time on the measurement and prints it, if there exists one with the specified name.
    ///
    /// - Parameter name: The name of the measurement
    public func stop(print name: Measurement.Name) {
        guard let measurement = stop(name) else {
            debugPrint("No measurement with name \(name) found.")
            return
        }
        
        print(measurement: measurement)
    }
    
    private func print(measurement: Measurement) {
        var items: [String] = [
            "\(self)[\(measurement)]"
        ]
        
        if measurement.lapTimes.count > 1, let latestLap = measurement.lapTimes.last {
            items.append("Lap #\(measurement.lapTimes.endIndex): \(latestLap)s")
        }
        
        if let totalDuration = measurement.totalDuration {
            items.append("Total: \(totalDuration)s")
        }
        
        debugPrint(items, separator: " - ")
    }
    
}

// MARK: - Stop measurements

extension Timekeeper {
    
    /// Sets the end time on all current measurements, removes them
    /// from the timekeeper instance and returns them.
    ///
    /// - Returns: All stopped measurements
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
    
    /// Sets the end time on all current measurements, removes them
    /// from the time keeper and print all of them.
    public func stopAllPrint() {
        stopAll().forEach { print(measurement: $0) }
    }
    
    /// Remove all current measurements from the timekeeper.
    public func clear() {
        lockWrite()
        defer { unlock() }
        
        self.measurements.removeAll()
    }
    
}

// MARK: - Custom String Convertible Conformance

extension Timekeeper: CustomStringConvertible {
    
    /// A textual representation of the timekeeper.
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
