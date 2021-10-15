//
//  Combine+Measure.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

#if canImport(Combine)
import Combine


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func measurementStart(_ name: Measurement.Name) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self) { _ in
            Timekeeper.default.start(name)
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func measurementLap(_ name: Measurement.Name) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self) { _ in
            Timekeeper.default.lap(print: name)
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func measurementStop(_ name: Measurement.Name) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self) { _ in
            Timekeeper.default.stop(print: name)
        }
    }
    
}
#endif
