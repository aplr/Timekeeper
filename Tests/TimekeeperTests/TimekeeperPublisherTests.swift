import XCTest
import Combine
@testable import Timekeeper

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TimekeeperPublisherTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    private enum TestError: Error {
        case testStopOnError
    }
    
    override func tearDown() {
        super.tearDown()
        
        Timekeeper.default.clear()
    }
    
    private func makeFuture() -> Future<String, Never> {
        Future<String, Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                promise(.success("Hello World!"))
            }
        }
    }

    func testMeasurePublisher() {
        let expectation = XCTestExpectation()
                
        var timing: Timing?
                        
        makeFuture()
            .measure("measurement", onStop: { timing = $0 })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let timing = timing else {
            return XCTFail()
        }
        
        XCTAssertEqual(timing.state, .stopped)
    }
    
    func testMeasurePublisherStopsOnFailure() {
        let expectation = XCTestExpectation()
                
        var timing: Timing?
                        
        Fail<Void, Error>(error: TestError.testStopOnError)
            .measure("measurement", onStop: { timing = $0 })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let timing = timing else {
            return XCTFail()
        }
        
        XCTAssertEqual(timing.state, .stopped)
    }
    
    func testMeasurePublisherWithoutStopping() {
        let expectation = XCTestExpectation()
                        
        Just(())
            .measure("measurement", stopOnCompletion: false)
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let timing = Timekeeper.default["measurement"] else {
            return XCTFail()
        }
        
        XCTAssertEqual(timing.state, .running)
    }
    
    func testMeasureStartStopPublisher() {
        let expectation = XCTestExpectation()
        
        var timing: Timing?
        
        Just(())
            .measureStart("measurement")
            .flatMap({ self.makeFuture() })
            .measureStop("measurement", onMeasure: { timing = $0 })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let timing = timing else {
            return XCTFail()
        }
        
        XCTAssertEqual(timing.state, .stopped)
    }
    
    func testMeasureLapPublisher() {
        let expectation = XCTestExpectation()
        
        var lapTiming: Timing?
        var timing: Timing?
        
        Just(())
            .measureStart("measurement")
            .flatMap({ self.makeFuture() })
            .measureLap("measurement", onMeasure: { lapTiming = $0 })
            .measureStop("measurement", onMeasure: { timing = $0 })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let timing = timing, let lapTiming = lapTiming else {
            return XCTFail()
        }
        
        XCTAssertEqual(lapTiming.state, .running)
        XCTAssertEqual(timing.state, .stopped)
        XCTAssertEqual(timing.laps.count, 1)
    }
    
    func testWithMeasureStopPublisher() {
        let expectation = XCTestExpectation()
        
        var timing: Timing?
        
        Just(())
            .measureStart("measurement")
            .flatMap({ self.makeFuture() })
            .withMeasureStop("measurement")
            .map({ Optional($0.1) })
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { timing = $0 })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let timing = timing else {
            return XCTFail()
        }
        
        XCTAssertEqual(timing.state, .stopped)
    }
    
    func testWithMeasureLapPublisher() {
        let expectation = XCTestExpectation()
        
        var lapTiming: Timing?
        var timing: Timing?
        
        Just(())
            .measureStart("measurement")
            .flatMap({ self.makeFuture() })
            .withMeasureLap("measurement")
            .map({ Optional($0.1) })
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { lapTiming = $0 })
            .measureStop("measurement", onMeasure: { timing = $0 })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let timing = timing, let lapTiming = lapTiming else {
            return XCTFail()
        }
        
        XCTAssertEqual(lapTiming.state, .running)
        XCTAssertEqual(timing.state, .stopped)
        XCTAssertEqual(timing.laps.count, 1)
    }
    
    func testWithMeasureStopPublisherFailsWithTimingNotFound() {
        let expectation = XCTestExpectation()
                
        var error: Error?
        
        Just(())
            .withMeasureStop("measurement")
            .handleEvents(receiveCompletion: {
                guard case let .failure(err) = $0 else { return }
                error = err
            })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let error = error as? Timekeeper.Error else {
            return XCTFail()
        }
        
        XCTAssertEqual(error, Timekeeper.Error.timingNotFound)
    }
    
    func testWithMeasureLapPublisherFailsWithTimingNotFound() {
        let expectation = XCTestExpectation()
                
        var error: Error?
        
        Just(())
            .withMeasureLap("measurement")
            .handleEvents(receiveCompletion: {
                guard case let .failure(err) = $0 else { return }
                error = err
            })
            .fulfill(expectation: expectation)
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
        
        guard let error = error as? Timekeeper.Error else {
            return XCTFail()
        }
        
        XCTAssertEqual(error, Timekeeper.Error.timingNotFound)
    }
    
}

extension Publisher {
    
    func fulfill(expectation: XCTestExpectation) -> Cancellable {
        sink(receiveCompletion: { _ in
            expectation.fulfill()
        }, receiveValue: { _ in })
    }
    
}
