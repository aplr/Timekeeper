//
//  Timekeeper+Error.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 18.10.21.
//

import Foundation

extension Timekeeper {
    
    /// An error that occurs while interacting with Timekeeper.
    public enum Error: Swift.Error {
        /// An indication that the timing was not found with the information specified.
        case timingNotFound
    }
    
}
