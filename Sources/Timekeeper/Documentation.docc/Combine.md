# Time Combine Operations

Learn how to measure the duration of one or a sequence of Combine publishers.

## Overview

For now, we just covered how to measure timings in an imperative way. If you are using Apple's Combine framework, using Timekeeper becomes even more fun with the convenience methods it defines on the [`Publisher`](https://developer.apple.com/documentation/combine/publisher) type.

Consider the following [Future](https://developer.apple.com/documentation/combine/future) publisher, which emits `"Hello World!"` after one second and then succeeds.

```swift
let request = Future<String, Error> { promise in
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        promise(.success("Hello World!"))
    }
}
```

If you want to measure the duration of the `request` from subscription start to completion, you can use the `measure(_:stopOnCompletion:printOnStop:onStop:)` operator. It starts the timing when the subscription starts, and stops it on completion of the publisher.

```swift
request.measure("measurement").sink(...).store(in: &cancellables)

// Prints: Timekeeper[default][measurement] - Lap #1: 1.0s - Total: 1.0s
```

## Start and stop Timings in a Stream

If you want to manually specify when the timing should start and end, you can use the `measureStart(_:)` and `measureStop(_:)` operators. Both of them start / stop the timing when they receive a value from the upstream publisher. Using `measureLap(_:)`, you can also add laps to a series of publishers.

```swift
let uppercase = { (input: String) -> Future<String, Error> in
    Future<String, Error> { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            promise(.success(input.uppercased()))
        }
    }
}

Just(())
    .measureStart("measurement")
    .flatMap({ request })
    .measureLap("measurement")
    .flatMap({ uppercase($0) })
    .measureStop("measurement")
    .sink(...)
    .store(in: &cancellables)

// Prints: 
//   Timekeeper[default][measurement] - Lap #1: 1.0s
//   Timekeeper[default][measurement] - Lap #1: 2.0s - Total: 2.0s
```

## Work with Timings downstream

If you want to perform operations on the ``Timekeeper/Timing`` data in downstream publishers, use the `withMeasureLap(_:)` and `measureStop(_:)` operators. They publish a ``Timekeeper/TimingElement`` to downstream publishers, which is a typealias for the tuple `(Upstream.Output, Timing)`, where `Output` is the output type of the upstream publisher and `Timing` the timing which was just modified / stopped.

> Note: Unlike with the other operators, `withMeasureLap(_:)` and `withMeasureStop(_:)` fail if no timing was started for the provided `name`.

```swift
Just(())
    .measureStart("measurement")
    .flatMap({ request })
    .measureLap("measurement")
    .flatMap({ uppercase($0) })
    .withMeasureStop("measurement")
    .map({ $0.totalDuration })
    .sink(receiveCompletion: { _ in }, receiveValue: { print("Total Duration: \($0)s") })
    .store(in: &cancellables)
```
