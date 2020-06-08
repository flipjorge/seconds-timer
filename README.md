# STimer

![Swift](https://github.com/flipjorge/seconds-timer/workflows/Swift/badge.svg)
![SPM](https://img.shields.io/badge/spm-compatible-red)
![GitHub](https://img.shields.io/github/license/flipjorge/seconds-timer)


## What it does

Counts down seconds! It's a simplistic class with a few methods to run and control a timer that only uses seconds (sorry milliseconds).

Don't use it for clock precision stuff!


## How to use it

```swift
import SecondsTimer

class MyTimer {
    
    var timer:STimer
    
    init() {
        
        timer = STimer()
        timer.delegate = self  //set delegate to receive timer updates
        
        timer.start(60)  //starting timer with 60 seconds
        
        timer.pause()
        timer.stop()  //stops timer and resets the remaining seconds to 60
        
        timer.resume()
        
        print("is timer running: \(timer.isActive)")
        print("seconds remaining: \(timer.secondsRemaining)")
    }
}

extension MyTimer: STimerDelegate {
    
    func clock(_ clock: STimer, didStartWithSeconds seconds: Int) {
        print("Starting with \(seconds)")
    }
    
    func clock(_ clock: STimer, didTickWithSeconds seconds: Int) {
        print("\(seconds) seconds remaining")
    }
    
    func clock(_ clock: STimer, didStopAtSeconds seconds: Int) {
        print("Stops and reseted to \(seconds) seconds")
    }
    
    func clock(_ clock: STimer, didPauseAtSeconds seconds: Int) {
        print("Paused at \(seconds) seconds")
    }
    
    func clock(_ clock: STimer, didResumeWithSeconds seconds: Int) {
        print("Resuming with \(seconds) seconds remaning")
    }
    
    func clockDidEnd(_ clock: STimer) {
        print("Finish!")
    }
}
```
