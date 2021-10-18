//
//  Timekeeper+Combine.swift
//  Timekeeper
//
//  Created by Andreas Pfurtscheller on 15.10.21.
//

#if canImport(Combine)
import Combine

/// Type used to represent the combination of a publisher's output and a timing function's output.
public typealias TimingElement<Output> = (Output, Timing)

/// Type used to represent a closure which can be called with an optional timing.
public typealias OnMeasure = ((Timing?) -> Void)

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    /// Starts a new timing with the given name as soon as the publisher
    /// receives a subscription. If there was a timing with this name before,
    /// it is replaced by a new one. If `stopOnCompletion` is `true`, the
    /// timing will be stopped when the publisher receives completion.
    ///
    /// When providing the `onStop` closure, the timing won't be printed on stop,
    /// even if `printOnStop` is `true`. If no timing with the specified name
    /// exists, the `onMeasure` closure will be called with a `nil` value.
    ///
    /// - Parameter name: The name of the timing.
    /// - Parameter stopOnCompletion: Stop the timing on completion. Defaults to `true`.
    /// - Parameter printOnStop: Print the timing on completion. Defaults to `true`.
    /// - Parameter onStop:A closure which is called on completion with the current timing.
    /// - Returns: A publisher that starts a timing as soon it receives a subscription.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func measure(
        _ name: Timing.Name,
        stopOnCompletion: Bool = true,
        printOnStop: Bool = true,
        onStop: OnMeasure? = nil
    ) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self, receiveSubscription: { _ in
            Timekeeper.default.start(name)
        }, receiveOutput: nil, receiveCompletion: { _ in
            guard stopOnCompletion else { return }
            if let onStop = onStop {
                onStop(Timekeeper.default.stop(name))
            } else if printOnStop {
                Timekeeper.default.stop(print: name)
            } else {
                Timekeeper.default.stop(name)
            }
        }, receiveCancel: nil, receiveRequest: nil)
    }
    
    /// Starts a new timing with the given name each time the publisher
    /// receives a new value. If there was a timing with this name before,
    /// it is replaced by a new one.
    ///
    /// - Parameter name: The name of the timing.
    /// - Returns: A publisher that starts a timing each time it receives a new value.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func measureStart(_ name: Timing.Name) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self, receiveOutput: { _ in
            Timekeeper.default.start(name)
        }, receiveRequest: { _ in })
    }
    
    /// Adds a lap to the timing with the specified name and prints it, if there exists one.
    ///
    /// When providing the `onMeasure` closure, the timing won't be printed.
    /// Instead, the provided closure is called. If no timing with the specified name
    /// exists, the `onMeasure` closure will be called with a `nil` value.
    ///
    /// - Parameter name: The name of the timing.
    /// - Parameter onMeasure: A closure which is called with the current timing.
    /// - Returns: A publisher that adds a lap to a timing every time it receives a new value.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func measureLap(
        _ name: Timing.Name,
        onMeasure: OnMeasure? = nil
    ) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self, receiveOutput: { _ in
            if let onMeasure = onMeasure {
                onMeasure(Timekeeper.default.lap(name))
            } else {
                Timekeeper.default.lap(print: name)
            }
        }, receiveRequest: { _ in })
    }
    
    /// Sets the end time on the timing with the specified name and prints it
    /// each time the publisher receives a new value.
    ///
    /// When providing the `onMeasure` closure, the timing won't be printed.
    /// Instead, the provided closure is called. If no timing with the specified name
    /// exists, the `onMeasure` closure will be called with a `nil` value.
    ///
    /// - Parameter name: The name of the timing.
    /// - Parameter onMeasure: A closure which is called with the current timing.
    /// - Returns: A publisher that stops a timing every time it receives a new value.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func measureStop(
        _ name: Timing.Name,
        onMeasure: OnMeasure? = nil
    ) -> Publishers.HandleEvents<Self> {
        Publishers.HandleEvents(upstream: self, receiveOutput: { _ in
            if let onMeasure = onMeasure {
                onMeasure(Timekeeper.default.stop(name))
            } else {
                Timekeeper.default.stop(print: name)
            }
        }, receiveRequest: { _ in })
    }
    
    /// Adds a lap to the timing with the specified name and emits the current
    /// timing alongside the output received from an upstream publisher.
    ///
    /// If no timing was found with the specified name, the publisher fails with the
    /// error `Timekeeper.Error.timingNotFound`.
    ///
    /// - Parameter name: The name of the timing.
    /// - Returns: A publisher that emits elements which are a combination of the
    ///            upstream output and the current timing.
    public func withMeasureLap(
        _ name: Timing.Name
    ) -> Publishers.TryMap<Self, TimingElement<Output>> {
        Publishers.TryMap(upstream: self) {
            if let timing = Timekeeper.default.lap(name) {
                return ($0, timing)
            } else {
                throw Timekeeper.Error.timingNotFound
            }
        }
    }
    
    /// Sets the end time on the timing with the specified name and emits the
    /// current timing alongside the output received from an upstream publisher.
    ///
    /// If no timing was found with the specified name, the publisher fails with the
    /// error `Timekeeper.Error.timingNotFound`.
    ///
    /// - Parameter name: The name of the timing.
    /// - Returns: A publisher that emits elements which are a combination of the
    ///            upstream output and the current timing.
    public func withMeasureStop(
        _ name: Timing.Name
    ) -> Publishers.TryMap<Self, TimingElement<Output>> {
        Publishers.TryMap(upstream: self) {
            if let timing = Timekeeper.default.stop(name) {
                return ($0, timing)
            } else {
                throw Timekeeper.Error.timingNotFound
            }
        }
    }
    
}
#endif
