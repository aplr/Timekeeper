# Working with Recorded Timings

Learn how to get timing data for each lap, access raw timings and convenience properties.

## Overview

The basic examples covered how to start and stop timers and how to use lap times. However, the methods introduced only allow for printing the current state. With Timekeeper, you can also access the underlying timings for each lap, providing you with the raw measurements and some convenience properties.

If you not only want to print the timings but also access them, e.g. in order to do calculations, Timekeeper got your back. You can use ``Timekeeper/Timekeeper/stop(_:)`` or ``Timekeeper/Timekeeper/lap(_:)``, both of which return the timing in its current state.

> Note: Keep in mind that a ``Timekeeper/Timing`` is a struct, not a class. Its properties only reflect the timings at the time of calling ``Timekeeper/Timekeeper/lap(_:)`` or ``Timekeeper/Timekeeper/stop(_:)``.

```swift
// Start a new timing
Timekeeper.shared.start("measurement")

for _ in 0..<100 {
    operationToMeasure()

    // Records a lap without printing
    Timekeeper.shared.lap("measurement")
}

// Stops the timing and returns it without printing
let timing = Timekeeper.shared.stop("measurement")
```

The code above shows you how to retrieve the timing from Timekeeper after stopping the timer. You could retrieve intermediate timings from the ``Timekeeper/Timekeeper/lap(_:)`` function as well.

## Accessing Timing Data

The timing struct provides you with the ``Timekeeper/Timing/start`` and ``Timekeeper/Timing/end`` times, as well as with all intermediate ``Timekeeper/Timing/laps``.

> Note: All times are measured in seconds relative to the absolute reference date of Jan 1 2001 00:00:00 GMT. Timekeeper internally calls [`CFAbsoluteTimeGetCurrent()`](https://developer.apple.com/documentation/corefoundation/1543542-cfabsolutetimegetcurrent) in order to generate these timestamps.

If the timer was stopped and the ``Timekeeper/Timing/end`` time was set, the ``Timekeeper/Timing/totalDuration`` property returns the difference between end and start time in seconds.

The ``Timekeeper/Timing/lapTimes`` property on the timing returns a list of all time deltas between the individual measurement points.

The possible number of time deltas in the list relates to the recorded times as follows:
- `0`, if only the start time and no internediate laps nor the end time is set.
- `n`, if the start time and `n` intermediate laps are set.
- `n+1` if the start time, `n` intermediate laps and the end time is set.

This implies that a stopped timing with no intermediate laps contains exactly 1 lap time delta.

There are also some mathematical functions pre-defined on the lap times. These include ``Timekeeper/Timing/lapTimeMedian`` for the median lap time, ``Timekeeper/Timing/lapTimeAverage`` for the arithmetic mean of the lap times, ``Timekeeper/Timing/lapTimeStandardDeviation`` for the standard deviation 𝜎 as well as ``Timekeeper/Timing/lapTimeVariance`` for the variance 𝜎² of the set of lap times.

## Topics

### Accessing Timing Data

- ``Timekeeper/Timing``
