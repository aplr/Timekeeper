//
//  Measurement.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation


/// A struct that describes a time measurement
public struct Measurement: CustomStringConvertible {
    
    public typealias Name = String
    
    public typealias Lap = Double
    
    /// The name of the measurement
    public let name: Name
    
    /// The start time of the measurement
    public var start: Double
    
    /// The end time of the measurement.
    /// It is `nil` if the measurement was not stopped.
    public var end: Double?
    
    /// A list of laps. Each lap item describes the absolute time
    /// it was added. If you want the deltas between each
    /// measurement points, look at `lapTimes` instead.
    public var laps = [Lap]()
    
    /// Creates a new Measurement, with the start time set to `CFAbsoluteTimeGetCurrent`.
    ///
    /// - Parameter name: The name of the measurement
    init(_ name: Name) {
        self.name = name
        self.start = CFAbsoluteTimeGetCurrent()
    }
    
    /// The total duration of the measurement.
    /// Returns `nil` if the measurement was not stopped.
    var totalDuration: Double? {
        end.map({ $0 - start })
    }
    
    /// A list of deltas between all measurement points.
    /// This includes start, end and all intermediate laps.
    var lapTimes: [Double] {
        (laps + [end]).compactMap({ $0 }).reduce(([], start)) {
            ($0.0 + [$1 - $0.1], $1)
        }.0
    }
    
    /// The average of all lap times.
    var lapTimeAverage: Double {
        lapTimes.average
    }
    
    /// The median of all lap times.
    var lapTimeMedian: Double? {
        lapTimes.median
    }
    
    /// The variance of all lap times.
    var lapTimeVariance: Double? {
        guard let median = lapTimeMedian else { return nil }
        
        return lapTimes.reduce(0, { $0 + pow($1 - median, 2) }) / Double(lapTimes.count - 1)
    }
    
    public var description: String {
        name
    }
    
}
