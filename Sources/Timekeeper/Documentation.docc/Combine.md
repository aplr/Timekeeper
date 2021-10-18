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

If you want to measure the duration of the `request` from subscription start to completion, you can use the `measure(_:stopOnCompletion:printOnStop:onStop:)` helper.

```swift
request.measure("measurement").sink(...).store(in: &cancellables)
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
