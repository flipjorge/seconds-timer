//  MIT License
//
//  Copyright (c) 2020 Filipe Jorge
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public class STimer {
    
    // MARK: - Initializers
    public init() { }
    
    // MARK: - Delegate
    public var delegate: STimerDelegate?
    
    // MARK: - Properties
    private var _secondsRemaining: Int = 0
    private var _startingSeconds: Int = 0
    private var _timer: Timer?
    
    public var secondsRemaining: Int {
        return _secondsRemaining
    }
    
    public var startingSeconds: Int {
        return _startingSeconds
    }
    
    public var isActive: Bool {
        return _timer?.isValid ?? false
    }
    
    // MARK: - Start
    public func start(_ seconds: Int) {
        guard seconds > 0 else { return }
        
        _secondsRemaining = seconds
        _startingSeconds = _secondsRemaining
        
        _startTimer()
        
        self.delegate?.clock(self, didStartWithSeconds: _secondsRemaining)
    }
    
    private func _startTimer() {
        _timer = Timer.init(timeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            //
            self._secondsRemaining -= 1
            self.delegate?.clock(self, didTickWithSeconds: self._secondsRemaining)
            
            if(self._secondsRemaining <= 0)
            {
                timer.invalidate()
                if self._timer == timer {
                    self._timer = nil
                }
                self.delegate?.clockDidEnd(self)
            }
        }
        
        guard let _timer = _timer else { return }
        _timer.tolerance = 0.1
        
        RunLoop.current.add(_timer, forMode: .common)
    }
    
    // MARK: - Stop
    public func stop() {
        _timer?.invalidate()
        _timer = nil
        
        _secondsRemaining = _startingSeconds
        
        self.delegate?.clock(self, didStopAtSeconds: _secondsRemaining)
    }
    
    // MARK: - Pause
    public func pause() {
        _timer?.invalidate()
        _timer = nil
        
        self.delegate?.clock(self, didPauseAtSeconds: _secondsRemaining)
    }
    
    // MARK: - Resume
    public func resume() {
        guard _secondsRemaining > 0 else { return }
        guard !isActive else { return }
        
        _startTimer()
        
        self.delegate?.clock(self, didResumeWithSeconds: _secondsRemaining)
    }
}
