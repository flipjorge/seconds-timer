import XCTest
@testable import SecondsTimer

final class STimerTests: XCTestCase {
    
    // MARK: - Setup
    var clock: STimer!
    
    override func setUp() {
        super.setUp()
        clock = STimer()
    }
    
    override func tearDown() {
        super.tearDown()
        clock.delegate = nil
        clock = nil
    }
    
    // MARK: - Start
    func test_start_givenValidSeconds_isActive() {
        clock.start(3)
        
        XCTAssertTrue(clock.isActive)
    }
    
    func test_start_givenValidSeconds_initializesWithGivenSeconds() {
        clock.start(3)
        
        XCTAssertEqual(clock?.startingSeconds, 3)
        XCTAssertEqual(clock?.secondsRemaining, 3)
    }
    
    func test_start_givenZeroSeconds_staysInactive() {
        clock.start(0)
        
        XCTAssertFalse(clock.isActive)
    }
    
    func test_start_givenNegativeSeconds_staysInactive() {
        clock.start(-1)
        
        XCTAssertFalse(clock.isActive)
        XCTAssertNotEqual(clock.secondsRemaining, -1)
    }
    
    func test_start_secondsDecrease() {
        clock.start(3)
        
        let exp = expectation(description: "Seconds decrease")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertLessThan(clock.secondsRemaining, 3)
        } else {
            XCTFail("secondsRemaining should be less than 3, is getting \(clock.secondsRemaining)")
        }
    }
    
    func test_start_staysAtZeroOnEnd() {
        clock.start(2)
        
        let exp = expectation(description: "Stays at zero on end")
        let result = XCTWaiter.wait(for: [exp], timeout: 3)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertEqual(clock.secondsRemaining, 0)
        } else {
            XCTFail("secondsRemaining should be 0, is getting \(clock.secondsRemaining)")
        }
    }
    
    func test_start_stopsTimerOnEnd() {
        clock.start(2)
        
        let exp = expectation(description: "Stops on end")
        let result = XCTWaiter.wait(for: [exp], timeout: 3)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertFalse(clock.isActive)
        } else {
            XCTFail("Clock should be inactive")
        }
    }
    
    // MARK: - Notifications
    func test_start_notifiesDidStart() {
        let exp = expectation(description: "Notifies DidStart")
        let clockDelegate = ClockDelegateMock()
        clockDelegate.clockDidStartWithSeconds = { clock, seconds in
            XCTAssertEqual(seconds, 1)
            exp.fulfill()
        }
        
        clock.delegate = clockDelegate
        clock.start(1)
        
        wait(for: [exp], timeout: 3)
    }
    
    func test_start_notifiesTick() {
        let exp = expectation(description: "Notifies DidTick")
        
        let clockDelegate = ClockDelegateMock()
        clockDelegate.clockDidTickWithSeconds = { clock, seconds in
            XCTAssertEqual(seconds, 1)
            exp.fulfill()
        }
        
        clock.delegate = clockDelegate
        clock.start(2)
        
        wait(for: [exp], timeout: 3)
    }
    
    func test_start_notifiesDidEnd() {
        let exp = expectation(description: "Notifies DidEnd")
        
        let clockDelegate = ClockDelegateMock()
        clockDelegate.clockDidEnd = { clock in
            XCTAssertFalse(clock.isActive)
            XCTAssertEqual(clock.secondsRemaining, 0)
            exp.fulfill()
        }
        
        clock.delegate = clockDelegate
        clock.start(2)
        
        wait(for: [exp], timeout: 3)
    }
    
    // MARK: - Stop
    func test_stop_changesToInactive() {
        clock.start(2)
        XCTAssertTrue(clock.isActive)
        clock.stop()
        XCTAssertFalse(clock.isActive)
    }
    
    func test_stop_stopsCounting() {
        clock.start(2)
        clock.stop()
        
        let exp = expectation(description: "Stops Counting")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertFalse(clock.isActive)
            XCTAssertEqual(clock.secondsRemaining, 2)
        } else {
            XCTFail()
        }
    }
    
    func test_stop_resetsTime() {
        clock.start(3)
        
        let exp = expectation(description: "Resets time")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            clock.stop()
            XCTAssertFalse(clock.isActive)
            XCTAssertEqual(clock.secondsRemaining, 3)
        } else {
            XCTFail()
        }
    }
    
    func test_stop_notifiesDidStop() {
        let exp = expectation(description: "Notifies Did Stop")
        
        let clockDelegate = ClockDelegateMock()
        clockDelegate.clockDidStopAtSeconds = { clock, seconds in
            XCTAssertEqual(seconds, 2)
            XCTAssertFalse(clock.isActive)
            exp.fulfill()
        }
        
        clock.delegate = clockDelegate
        clock.start(2)
        clock.stop()
        
        wait(for: [exp], timeout: 3)
    }
    
    // MARK: - Pause
    func test_pause_changesToInactive() {
        clock.start(2)
        XCTAssertTrue(clock.isActive)
        clock.pause()
        XCTAssertFalse(clock.isActive)
    }
    
    func test_pause_stopsCounting() {
        clock.start(2)
        clock.pause()
        
        let exp = expectation(description: "Stops Counting")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertFalse(clock.isActive)
            XCTAssertEqual(clock.secondsRemaining, 2)
        } else {
            XCTFail()
        }
    }
    
    func test_pause_notifiesDidEnd() {
        let exp = expectation(description: "Notifies DidPause")
        
        let clockDelegate = ClockDelegateMock()
        clockDelegate.clockDidPauseAtSeconds = { clock, seconds in
            XCTAssertEqual(seconds, 2)
            XCTAssertFalse(clock.isActive)
            exp.fulfill()
        }
        
        clock.delegate = clockDelegate
        clock.start(2)
        clock.pause()
        
        wait(for: [exp], timeout: 3)
    }
    
    // MARK: - Resume
    func test_resume_resumeCountingAfterPause() {
        clock.start(3)
        clock.pause()
        clock.resume()
        
        let exp = expectation(description: "Clock keeps counting")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(clock.isActive)
            XCTAssertLessThan(clock.secondsRemaining, 3)
        } else {
            XCTFail()
        }
    }
    
    func test_resume_keepsInactiveWhenThereIsntSecondsLeft() {
        clock.resume()
        XCTAssertFalse(clock.isActive)
    }
    
    func test_resume_keepsPlayingEvenWhenItsAlredyRunning() {
        clock.start(2)
        clock.resume()
        
        let exp = expectation(description: "Clock keeps counting")
        let result = XCTWaiter.wait(for: [exp], timeout: 1)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(clock.isActive)
            XCTAssertEqual(clock.secondsRemaining, 1)
        } else {
            XCTFail()
        }
    }
    
    func test_resume_notifiesDidResume() {
        let exp = expectation(description: "Notifies DidResume")
        
        let delegate = ClockDelegateMock()
        delegate.clockDidResumeWithSeconds = { clock, seconds in
            XCTAssertTrue(clock.isActive)
            exp.fulfill()
        }
        
        clock.delegate = delegate
        clock.start(2)
        clock.pause()
        clock.resume()
        
        wait(for: [exp], timeout: 1)
    }

    // MARK: - Clock Delegate Mock
    class ClockDelegateMock: STimerDelegate {
        
        var clockDidStartWithSeconds: ( (STimer, Int) -> Void )?
        var clockDidTickWithSeconds: ( (STimer, Int) -> Void )?
        var clockDidStopAtSeconds: ( (STimer, Int) -> Void )?
        var clockDidPauseAtSeconds: ( (STimer, Int) -> Void )?
        var clockDidResumeWithSeconds: ( (STimer, Int) -> Void )?
        var clockDidEnd: ( (STimer) -> Void )?
        
        func clock(_ clock: STimer, didStartWithSeconds seconds: Int) {
            clockDidStartWithSeconds?(clock, seconds)
        }
        
        func clock(_ clock: STimer, didTickWithSeconds seconds: Int) {
            clockDidTickWithSeconds?(clock, seconds)
        }
        
        func clock(_ clock: STimer, didStopAtSeconds seconds: Int) {
            clockDidStopAtSeconds?(clock, seconds)
        }
        
        func clock(_ clock: STimer, didPauseAtSeconds seconds: Int) {
            clockDidPauseAtSeconds?(clock, seconds)
        }
        
        func clock(_ clock:STimer, didResumeWithSeconds seconds: Int) {
            clockDidResumeWithSeconds?(clock, seconds)
        }
        
        func clockDidEnd(_ clock: STimer) {
            clockDidEnd?(clock)
        }
    }
}
