//
//  Collection+Median.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation


extension Collection where Element: BinaryInteger {
        
    var median: Double? {
        guard count > 0 else { return nil }
        
        let sorted = sorted()
        
        if sorted.count % 2 == 0 {
            return Double(sorted[sorted.count / 2])
        } else {
            return sorted[(sorted.count / 2 - 1) ..< (sorted.count / 2)].average
        }
    }
    
}

extension Collection where Element: BinaryFloatingPoint {
        
    var median: Double? {
        guard count > 0 else { return nil }
        
        let sorted = sorted()
        
        if sorted.count % 2 == 0 {
            return Double(sorted[sorted.count / 2])
        } else {
            return sorted[(sorted.count / 2 - 1) ..< (sorted.count / 2)].average
        }
    }

}
