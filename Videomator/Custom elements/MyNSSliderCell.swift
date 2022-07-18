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
    private let lineWidth: CGFloat = 8
    public var completionHandler: (() -> Void)?
    public var videoURL: URL? {
        didSet {
            self.pattern = [NSImage]()
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
        let layer = CALayer()
        layer.cornerRadius = 5
        self.controlView?.wantsLayer = true
        self.controlView?.layer = layer
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
        let rect = NSRect(x: knobRect.midX - self.lineWidth,
                          y: knobRect.origin.y,
                          width: self.lineWidth,
                          height: knobRect.height)
        let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        NSColor.white.withAlphaComponent(1).set()
        path.fill()
    }
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        
    }
    
    //MARK: - Supporting func
    private func setPreviews() async {
        guard let url = videoURL, let times = TimingManager.getTimeCodes(for: url, amount: self.requiredNumberOfCaptures) else { return }
        
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.maximumSize = CGSize(
            width: self.controlView!.frame.width,
            height: self.controlView!.frame.height
        )
        
        generator.generateCGImagesAsynchronously(forTimes: times) { _, image, _, result, _ in
            let newImage = NSImage(cgImage: image!, size: .zero)
            DispatchQueue.main.async {
                self.setPatterns(with: newImage)
            }
        }
    }
    
    public func setPatterns(with pattern: NSImage) {
        self.pattern.append(pattern)
        if CGFloat(self.pattern.count) >= self.requiredNumberOfCaptures {
            if let completionHandler = self.completionHandler {
                completionHandler()
            }
        }
    }
    
    private func getNextCapture(for image: NSImage, in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath(rect: rect)
        NSColor(patternImage: image).setFill()
        path.fill()
        return path
    }
    
}
