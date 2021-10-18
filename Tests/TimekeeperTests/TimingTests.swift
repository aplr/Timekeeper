import XCTest
@testable import Timekeeper

final class TimingTests: XCTestCase {
    
    func testTimingStateIsRunningWhenEndNil() {
        let timing = Timing("measurement")
        
        XCTAssertEqual(timing.state, .running)
    }
    
    func testTimingStateIsStoppedWhenEndNotNil() {
        var timing = Timing("measurement")
        
        timing.stop()
        
        XCTAssertEqual(timing.state, .stopped)
    }
    
    func testTimingAddsLap() {
        var timing = Timing("measurement")
        
        timing.lap()
        
        XCTAssertEqual(timing.laps.count, 1)
    }
    
    func testTimingStop() {
        var timing = Timing("measurement")
        
        timing.stop()
        
        XCTAssertNotNil(timing.end)
    }
    
    func testLapTimesIsEmptyWhenRunningWithoutLaps() {
        let timing = Timing("measurement")
        
        XCTAssert(timing.lapTimes.isEmpty)
    }
    
    func testLapTimesContainsOneItemWhenStoppedWithoutLaps() {
        var timing = Timing("measurement")
        
        Thread.sleep(forTimeInterval: 0.1)
        
        timing.stop()
        
        XCTAssertEqual(timing.lapTimes.count, 1)
        XCTAssertEqual(timing.lapTimes[0], 0.1, accuracy: 0.01)
    }
    
    func testLapTimesContainsTwoItemsWhenStoppedWithOneLap() {
        var timing = Timing("measurement")
                
        Thread.sleep(forTimeInterval: 0.1)
        
        timing.lap()
                
        Thread.sleep(forTimeInterval: 0.1)
        
        timing.stop()
        
        XCTAssertEqual(timing.lapTimes.count, 2)
        XCTAssertEqual(timing.lapTimes[0], 0.1, accuracy: 0.01)
        XCTAssertEqual(timing.lapTimes[1], 0.1, accuracy: 0.01)
    }
    
    func testTotalDurationIsNilWhenRunning() {
        let timing = Timing("measurement")
        
        XCTAssertEqual(timing.state, .running)
        XCTAssertNil(timing.totalDuration)
    }
    
    func testTotalDuration() {
        var timing = Timing("measurement")
        
        timing.start = 0
        timing.end = 10
        
        guard let totalDuration = timing.totalDuration else {
            return XCTFail()
        }
        
        XCTAssertEqual(totalDuration, 10, accuracy: .leastNonzeroMagnitude)
    }
    
    func testLapTimeAverageNilWhenRunningWithoutLaps() {
        let timing = Timing("measurement")
        
        XCTAssertNil(timing.lapTimeMedian)
    }
    
    func testLapTimeAverage() {
        var timing = Timing("measurement")
        
        timing.start = 0
        
        timing.laps.append(7)
        timing.laps.append(8)
        timing.laps.append(9)
        
        timing.end = 10
        
        XCTAssertEqual(timing.lapTimeAverage, 2.5, accuracy: .leastNonzeroMagnitude)
    }
    
    func testLapTimeMedianNilWhenRunningWithoutLaps() {
        let timing = Timing("measurement")
        
        XCTAssertNil(timing.lapTimeMedian)
    }
    
    func testLapTimeMedian() {
        var timing = Timing("measurement")
        
        timing.start = 0
        
        timing.laps.append(7)
        timing.laps.append(8)
        timing.laps.append(9)
        
        timing.end = 10
        
        guard let median = timing.lapTimeMedian else {
            return XCTFail()
        }
        
        XCTAssertEqual(median, 1, accuracy: .leastNonzeroMagnitude)
    }
    
    func testDescriptionWhenRunningWithoutLaps() {
        let timing = Timing("measurement")
        
        XCTAssertEqual(timing.description, "[measurement]")
    }
    
    func testDescriptionWhenStoppedWithoutLaps() {
        var timing = Timing("measurement")
        
        timing.start = 0
        timing.end = 10
        
        XCTAssertEqual(timing.description, "[measurement] - Lap #1: 10.0s - Total: 10.0s")
    }
    
    func testDescriptionWhenRunningWithLap() {
        var timing = Timing("measurement")
        
        timing.start = 0
        timing.laps.append(10)
        
        XCTAssertEqual(timing.description, "[measurement] - Lap #1: 10.0s")
    }
    
    func testDescriptionWhenStoppedWithLap() {
        var timing = Timing("measurement")
        
        timing.start = 0
        timing.laps.append(10)
        timing.end = 20
        
        XCTAssertEqual(timing.description, "[measurement] - Lap #2: 10.0s - Total: 20.0s")
    }
}
