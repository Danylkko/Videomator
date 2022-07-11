//
//  MyNSSliderCell.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 10.07.2022.
//

import Cocoa

class MyNSSliderCell: NSSliderCell {
    
    var pattern = [NSImage]()
    
    public func setPatterns(with pattern: NSImage, requiredAmount: Int) {
        self.pattern.append(pattern)
        if self.pattern.count == requiredAmount {
            self.controlView?.layoutSubtreeIfNeeded()
        }
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        if self.pattern.isEmpty {
            NSColor.magenta.setStroke()
        } else {
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
    
    private func getNextCapture(for image: NSImage, in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath(rect: rect)
        NSColor(patternImage: image).set()
        path.fill()
        return path
    }
    
    override func drawKnob(_ knobRect: NSRect) {
        let path = NSBezierPath(roundedRect: knobRect, xRadius: 4, yRadius: 4)
        NSColor.white.withAlphaComponent(0.8).set()
        path.fill()
    }
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        
    }
    
}
