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
    
    /// Starts a new measurement with the given name as soon as the publisher
    /// receives a subscription. If there was a measurement with this name before,
    /// it is replaced by a new one. If `stopOnCompletion` is `true`, the
    /// measurement will be stopped when the publisher receives completion.
    ///
    /// - Parameter name: The name of the measurement
    /// - Parameter stopOnCompletion: Stop
    /// - Returns: A publisher that starts a measurement as soon it receives a subscription.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func measure(
        _ name: Measurement.Name,
        stopOnCompletion: Bool = false
    ) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self, receiveSubscription: { _ in
            Timekeeper.default.start(name)
        }, receiveOutput: nil, receiveCompletion: { _ in
            guard stopOnCompletion else { return }
            Timekeeper.default.stop(name)
        }, receiveCancel: nil, receiveRequest: nil)
    }
    
    /// Starts a new measurement with the given name each time the publisher
    /// receives a new value. If there was a measurement with this name before,
    /// it is replaced by a new one.
    ///
    /// - Parameter name: The name of the measurement
    /// - Returns: A publisher that starts a measurement each time it receives a new value.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func measure(_ name: Measurement.Name) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self) { _ in
            Timekeeper.default.start(name)
        }
    }
    
    /// Adds a lap to the measurement and prints it, if there exists one with the specified name.
    ///
    /// - Parameter name: The name of the measurement
    /// - Returns: A publisher that adds a lap to a measurement every time it receives a new value.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func measurementLap(_ name: Measurement.Name) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self) { _ in
            Timekeeper.default.lap(print: name)
        }
    }
    
    /// Sets the end time on the measurement and prints it each time the publisher
    /// receives a new value.
    ///
    /// - Parameter name: The name of the measurement
    /// - Returns: A publisher that stops a measurement every time it receives a new value.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func measurementStop(_ name: Measurement.Name) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self) { _ in
            Timekeeper.default.stop(print: name)
        }
    }
    
}
#endif
