//
//  Timing.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation


/// A struct that describes a timing.
public struct Timing: Equatable {
    
    /// A type that represents the state of a timing.
    public enum State {
        /// The timing is running and was not stopped.
        case running
        
        /// The timing was stopped and accepts no further changes.
        case stopped
    }
    
    /// Type used to represent the name of a timing.
    public typealias Name = String
    
    /// Type used to represent a single lap, which is a specific point in time.
    public typealias Lap = Double
    
    /// The name of the timing.
    public let name: Name
    
    /// The start time of the timing.
    public var start: Double
    
    /// The end time of the timing.
    /// It is `nil` if the timing was not stopped.
    public var end: Double?
    
    /// A list of laps. Each lap item describes the absolute time
    /// it was added. If you want the deltas between each
    /// timing points, look at `lapTimes` instead.
    public var laps = [Lap]()
    
    /// The state of the timing. Either ``State-swift.enum/running``, if the
    /// timing was not explicitly stopped, or ``State-swift.enum/stopped``.
    public var state: State {
        end.map({ _ in .stopped }) ?? .running
    }
    
    /// Creates a new timing, with the start time set
    /// to `CFAbsoluteTimeGetCurrent`.
    ///
    /// - Parameter name: The name of the timing
    init(_ name: Name) {
        self.name = name
        self.start = CFAbsoluteTimeGetCurrent()
    }
    
    /// The total duration of the timing.
    /// Returns `nil` if the timing was not stopped.
    public var totalDuration: Double? {
        end.map({ $0 - start })
    }

    // MARK: - Lap Times
    
    /// A list of time deltas in seconds between all timing points.
    /// This includes start, end and all intermediate laps.
    ///
    /// Possible number of lap time deltas are:
    /// - `0`, if only the start time and no internediate laps nor the end time is set.
    /// - `n`, if the start time and `n` intermediate laps are set.
    /// - `n+1` if the start time, `n` intermediate laps and the end time is set.
    ///
    /// This implies that a stopped timing with no intermediate laps
    /// contains exactly 1 lap time delta.
    public var lapTimes: [Double] {
        (laps + [end]).compactMap({ $0 }).reduce(([], start)) {
            ($0.0 + [$1 - $0.1], $1)
        }.0
    }
    
    /// The average of all lap times.
    public var lapTimeAverage: Double {
        lapTimes.average
    }
    
    /// The median of all lap times.
    public var lapTimeMedian: Double? {
        lapTimes.median
    }
    
    /// The standard deviation (𝜎) of all lap times.
    public var lapTimeStandardDeviation: Double? {
        guard let median = lapTimeMedian else { return nil }
        
        return lapTimes.reduce(0, { $0 + abs($1 - median) }) / Double(lapTimes.count)
    }
    
    /// The variance (𝜎²) of all lap times.
    public var lapTimeVariance: Double? {
        guard let median = lapTimeMedian else { return nil }
        
        return lapTimes.reduce(0, { $0 + pow($1 - median, 2) }) / Double(lapTimes.count - 1)
    }
    
    mutating func stop() {
        end = CFAbsoluteTimeGetCurrent()
    }
    
    mutating func lap() {
        laps.append(CFAbsoluteTimeGetCurrent())
    }
    
}

// MARK: - Custom String Convertible Conformance

extension Timing: CustomStringConvertible {
    
    /// A textual representation of the timing.
    public var description: String {
        var items: [String] = [
            "[\(name)]"
        ]
        
        if lapTimes.count > 0, let latestLap = lapTimes.last {
            items.append("Lap #\(lapTimes.endIndex): \(latestLap)s")
        }
        
        if let totalDuration = totalDuration {
            items.append("Total: \(totalDuration)s")
        }
        
        return items.joined(separator: " - ")
    }

}
