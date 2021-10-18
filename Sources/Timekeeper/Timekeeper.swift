//
//  Timekeeper.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation

/// A timing class allowing to keep track of the duration of code.
public class Timekeeper {
    
    /// The default timekeeper instance
    public static let `default` = Timekeeper("default")
    
    /// The name of this timekeeper. Used for identifying in the logs.
    let label: String
    
    /// The lock used for synchronizing access to the underlying dict.
    var lock = pthread_rwlock_t()
    
    /// The dictionary storing all current timings
    var timings = [Timing.Name: Timing]()
    
    /// Creates a new Timekeeper instance with the specified label.
    ///
    /// - Parameter label: The name of the timekeeper instance
    public init(_ label: String) {
        self.label = label
        
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    /// Accesses the timing with the specified name.
    ///
    /// - Parameter name: The name of the timing.
    public subscript(_ name: Timing.Name) -> Timing? {
        lockRead()
        defer { unlock() }
        return timings[name]
    }

}

// MARK: - Measuring time

extension Timekeeper {
    
    /// Starts a new timing, setting the start time to the current system
    /// absolute time using `CFAbsoluteTimeGetCurrent`. If there
    /// was a timing with this name before, it is replaced by a new one.
    ///
    /// - Parameter name: The name of the timing.
    /// - Returns: The timing.
    @discardableResult
    public func start(_ name: Timing.Name) -> Timing {
        lockWrite()
        defer { unlock() }
        
        let timing = Timing(name)
        
        timings[name] = timing
        
        return timing
    }
    
    /// Adds a lap to the timing, if one exists with the specified name.
    /// Otherwise, the function will just return nil.
    ///
    /// - Parameter name: The name of the timing.
    /// - Returns: The timing.
    @discardableResult
    public func lap(_ name: Timing.Name) -> Timing? {
        lockWrite()
        defer { unlock() }
        
        guard var timing = timings[name] else { return nil }
        
        timing.lap()
        
        timings[name] = timing
        
        return timing
    }
    
    /// Sets the end time on the timing if one exists with the specified name,
    /// removes it from the timekeeper instance and returns it.
    ///
    /// - Parameter name: The name of the timing.
    /// - Returns: The timing.
    @discardableResult
    public func stop(_ name: Timing.Name) -> Timing? {
        lockWrite()
        defer { unlock() }
        
        guard var timing = timings.removeValue(forKey: name) else { return nil }
        
        timing.stop()
        
        return timing
    }
    
}

// MARK: - Convenience print functions

extension Timekeeper {
    
    /// Adds a lap to the timing and prints it, if there exists one with the specified name.
    ///
    /// - Parameter name: The name of the timing.
    public func lap(print name: Timing.Name) {
        guard let timing = lap(name) else {
            debugPrint("No timing with name \(name) found.")
            return
        }
        
        print(timing: timing)
    }
    
    /// Sets the end time on the timing and prints it, if there exists one with the specified name.
    ///
    /// - Parameter name: The name of the timing.
    public func stop(print name: Timing.Name) {
        guard let timing = stop(name) else {
            debugPrint("No timing with name \(name) found.")
            return
        }
        
        print(timing: timing)
    }
    
    private func print(timing: Timing) {
        debugPrint("\(self)[\(timing)]")
    }
    
}

// MARK: - Stop timings

extension Timekeeper {
    
    /// Sets the end time on all current timing, removes them
    /// from the timekeeper instance and returns them.
    ///
    /// - Returns: All stopped timing.
    @discardableResult
    public func stopAll() -> [Timing] {
        lockWrite()
        defer { unlock() }
        
        let time = CFAbsoluteTimeGetCurrent()
        
        let timing = timings.values.map({ timing -> Timing in
            var value = timing
            value.end = time
            return value
        })
        
        self.timings.removeAll()
        
        return timing
    }
    
    /// Sets the end time on all current timings, removes them
    /// from the time keeper and print all of them.
    public func stopAllPrint() {
        stopAll().forEach { print(timing: $0) }
    }
    
    /// Remove all current timings from the timekeeper.
    public func clear() {
        lockWrite()
        defer { unlock() }
        
        self.timings.removeAll()
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
