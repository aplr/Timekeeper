import XCTest
@testable import Timekeeper

final class TimekeeperTests: XCTestCase {
    
    func testStartNewTiming() {
        let timekeeper = Timekeeper("Chrono")
        
        let timing = timekeeper.start("measurement")
        
        XCTAssertEqual(timekeeper["measurement"], timing)
    }
    
    func testStartNewTimingOverwritesExisting() {
        let timekeeper = Timekeeper("Chrono")
        
        let timing1 = timekeeper.start("measurement")
        let timing2 = timekeeper.start("measurement")
        
        XCTAssertNotEqual(timing1, timing2)
    }
    
    func testLapOnNonExistingTiming() {
        let timekeeper = Timekeeper("Chrono")
        
        let timing = timekeeper.lap("measurement")
        
        XCTAssertNil(timing)
    }
    
    func testLap() {
        let timekeeper = Timekeeper("Chrono")
        
        timekeeper.start("measurement")
        let timing = timekeeper.lap("measurement")
        
        guard let timing = timing else {
            return XCTFail()
        }
        
        XCTAssertEqual(timing.laps.count, 1)
    }
    
    func testStopOnNonExistingTiming() {
        let timekeeper = Timekeeper("Chrono")
        
        let timing = timekeeper.stop("measurement")
        
        XCTAssertNil(timing)
    }
    
    func testStop() {
        let timekeeper = Timekeeper("Chrono")
        
        timekeeper.start("measurement")
        let timing = timekeeper.stop("measurement")
        
        guard let timing = timing else {
            return XCTFail()
        }
        
        XCTAssertEqual(timing.state, .stopped)
    }
    
    func testStopRemovesTiming() {
        let timekeeper = Timekeeper("Chrono")
        
        timekeeper.start("measurement")
        timekeeper.stop("measurement")
        
        XCTAssertNil(timekeeper["measurement"])
    }
    
    func testStopAll() {
        let timekeeper = Timekeeper("Chrono")
        
        timekeeper.start("measurement1")
        timekeeper.start("measurement2")
        
        timekeeper.stopAll()
        
        XCTAssertEqual(timekeeper.timings.count, 0)
    }
    
    func testClear() {
        let timekeeper = Timekeeper("Chrono")
        
        timekeeper.start("measurement1")
        timekeeper.start("measurement2")
        
        timekeeper.clear()
        
        XCTAssertEqual(timekeeper.timings.count, 0)
    }
    
}
