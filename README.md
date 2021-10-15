<h1>
    <img src="https://raw.githubusercontent.com/aplr/Timekeeper/main/Logo.png" height="23" />
    Timekeeper
</h1>

![Build](https://github.com/aplr/Timekeeper/workflows/Build/badge.svg?branch=main)
![Documentation](https://github.com/aplr/Timekeeper/workflows/Documentation/badge.svg)

Timekeeper is an easy-to-use time measurement library written in Swift, with support for iOS, tvOS, watchOS and macOS.

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

## Usage

```swift
import Timekeeper

// Start a new measurement
Timekeeper.shared.start("measurement")

// Print the elapsed time since start
Timekeeper.shared.lap(print: "measurement")

// Print the elapsed time since the last lap
Timekeeper.shared.lap(print: "measurement")

// Print the elapsed time since the last lap and start and clears the measurement
Timekeeper.shared.stop(print: "measurement")
```

```swift
// Start a new measurement
Timekeeper.shared.start("measurement")

// Add a new lap and return the measurement
let measurement = Timekeeper.shared.lap("measurements")

// Stop the timer and return the measurement
let measurement = Timekeeper.shared.stop("measurement")
```

## Documentation

Documentation is available [here](https://timekeeper.aplr.io) and provides a comprehensive documentation of the library's public interface. Expect usage examples and guides to be added shortly. For now, have a look at the demo app in the *Example* directory.

## License
Timekeeper is licensed under the [MIT License](https://github.com/aplr/Timekeeper/blob/main/LICENSE).
