//
//  Measurement.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation


public struct Measurement: CustomStringConvertible {
    
    public typealias Name = String
    
    public typealias Lap = Double
    
    public let name: Name
    public var start: Double
    public var end: Double?
    
    public var laps = [Lap]()
    
    init(_ name: Name) {
        self.name = name
        self.start = CFAbsoluteTimeGetCurrent()
    }
    
    var totalDuration: Double {
        (end ?? CFAbsoluteTimeGetCurrent()) - start
    }
    
    var lapTimes: [Double] {
        (laps + [end]).compactMap({ $0 }).reduce(([], start)) {
            ($0.0 + [$1 - $0.1], $1)
        }.0
    }
    
    var lapTimeAverage: Double {
        lapTimes.average
    }
    
    var lapTimeMedian: Double? {
        lapTimes.median
    }
    
    var lapTimeVariance: Double? {
        guard let median = lapTimeMedian else { return nil }
        
        return lapTimes.reduce(0, { $0 + pow($1 - median, 2) }) / Double(lapTimes.count - 1)
    }
    
    public var description: String {
        name
    }
    
}
