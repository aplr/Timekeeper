# ``Timekeeper``

Timekeeper is an easy-to-use timing library written in Swift, with support for iOS, tvOS, watchOS and macOS.

## Overview

Timekeeper makes it relly easy to measure timings, as shown in the code snippet below.

```swift
import Timekeeper

// Start a new timing
Timekeeper.shared.start("measurement")

for _ in 0..<100 {
    operationToMeasure()

    // Print the elapsed time since start or the last lap
    Timekeeper.shared.lap(print: "measurement")
}

// Print the elapsed time since the last lap
// as well as the total time
Timekeeper.shared.stop(print: "measurement")
```

## Installation

Timekeeper is available via the [Swift Package Manager](https://swift.org/package-manager/) which is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system and automates the process of downloading, compiling, and linking dependencies.

Once you have your Swift package set up, adding Timekeeper as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(
        url: "https://github.com/aplr/Timekeeper.git",
        .upToNextMajor(from: "0.0.1")
    )
]
```

## License
Timekeeper is licensed under the [MIT License](https://github.com/aplr/Timekeeper/blob/main/LICENSE).

## Topics

### Documentation

- <doc:Advanced>
- <doc:Combine>

### Timekeeper

- ``Timekeeper/Timekeeper``
- ``Timekeeper/Timing``
