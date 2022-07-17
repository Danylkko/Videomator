//
//  TimingManager.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 17.07.2022.
//

import Foundation
import AVFoundation

class TimingManager {
    
    static public func getTimingFor(currentValue: Double, of duration: Double) -> [NSValue] {
        let timing = currentValue * duration / 100
        let fraction = TimingManager.getFraction(x0: timing)
        let cmTiming = CMTime(value: CMTimeValue(fraction.0), timescale: CMTimeScale(fraction.1))
        print("fraction \(fraction.0) / \(fraction.1)")
        return [NSValue(time: cmTiming)]
    }
    
    static public func getTimeCodes(for url: URL, amount: CGFloat) -> [NSValue]? {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration.seconds
        var times = [NSValue]()
        var k: Double = 0
        
        k = duration / amount
        
        var sum = 0.0
        while sum < duration {
            let time = sum
            times.append(time as NSValue)
            sum += k
        }
        return times
    }
    
    static private func getFraction(x0: Double) -> (Int, Int) {
        var x = x0
        var a = floor(x)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > 0.01 * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = floor(x)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }
    
}
