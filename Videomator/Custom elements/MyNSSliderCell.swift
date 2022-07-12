//
//  MyNSSliderCell.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 10.07.2022.
//

import Cocoa
import AVKit
import AVFoundation

class MyNSSliderCell: NSSliderCell {
    
    //MARK: - Properties
    private var pattern = [NSImage]()
    public var completionHandler: (() -> Void)?
    public var videoURL: URL? {
        didSet {
            Task(priority: .userInitiated) {
                await self.setPreviews()
            }
        }
    }
    private var requiredNumberOfCaptures: CGFloat {
        self.controlView!.frame.width / self.controlView!.frame.height
    }
    
    //MARK: - Initializers
    override init() {
        super.init()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Inherited functions
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        if let _ = self.videoURL, CGFloat(self.pattern.count) >= self.requiredNumberOfCaptures {
            let path = NSBezierPath()
            for (index, elem) in self.pattern.enumerated() {
                let diff = cellFrame.width / CGFloat(self.pattern.count)
                let rect = NSRect(x: cellFrame.origin.x + diff * CGFloat(index),
                                  y: cellFrame.origin.y,
                                  width: controlView.frame.width / CGFloat(self.pattern.count),
                                  height: controlView.frame.height)
                path.append(self.getNextCapture(for: elem, in: rect))
            }
        }
        super.draw(withFrame: cellFrame, in: controlView)
    }

    override func drawKnob(_ knobRect: NSRect) {
        let path = NSBezierPath(roundedRect: knobRect, xRadius: 4, yRadius: 4)
        NSColor.white.withAlphaComponent(0.8).set()
//        path.lineWidth = 5
        path.fill()
    }
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        
    }
    
    //MARK: - Supporting func
    private func setPreviews() async {
        guard let url = videoURL, let times = self.getTimeCodes() else { return }
        
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.maximumSize = CGSize(
            width: self.controlView!.frame.height * 2,
            height: self.controlView!.frame.height
        )
        
        generator.generateCGImagesAsynchronously(forTimes: times) { _, image, _, result, _ in
            let newImage = NSImage(cgImage: image!, size: .zero)
            DispatchQueue.main.async {
                self.setPatterns(with: newImage)
                print(self.pattern.count)
            }
        }
    }
    
    private func getTimeCodes() -> [NSValue]? {
        guard let url = self.videoURL else { return nil }
        let asset = AVURLAsset(url: url)
        let numberOfFrames = self.requiredNumberOfCaptures
        let duration = CMTimeGetSeconds(asset.duration)
        var times = [NSValue]()
        var k: Double = 0
        
        if numberOfFrames > duration {
            k = duration / numberOfFrames
        } else {
            k = numberOfFrames / duration
        }
        
        var sum = 0.0
        while sum < duration {
            let time = sum
            times.append(time as NSValue)
            sum += k
        }
        return times
    }
    
    public func setPatterns(with pattern: NSImage) {
        self.pattern.append(pattern)
        if CGFloat(self.pattern.count) >= self.requiredNumberOfCaptures {
            self.controlView?.layoutSubtreeIfNeeded()
            if let completionHandler = self.completionHandler {
                completionHandler()
            }
        }
    }
    
    private func getNextCapture(for image: NSImage, in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath(rect: rect)
        NSColor(patternImage: image).set()
        path.fill()
        return path
    }
    
}
