//
//  Collection+Average.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

import Foundation


extension Collection where Element: BinaryInteger {
    
    var average: Double {
        Double(reduce(.zero, +)) / Double(count)
    }
    
}

extension Collection where Element: BinaryFloatingPoint {
    
    var average: Double {
        Double(reduce(.zero, +)) / Double(count)
    }

}
