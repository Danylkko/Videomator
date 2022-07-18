//
//  MyNSCellExtension.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 18.07.2022.
//

import Foundation

extension MyNSSliderCell {
    public func setShadow() {
        self.controlView?.shadow = NSShadow()
        self.controlView?.layer?.cornerRadius = 5.0
        self.controlView?.layer?.shadowOpacity = 1.0
        self.controlView?.layer?.shadowColor = NSColor.black.cgColor
        self.controlView?.layer?.shadowOffset = NSMakeSize(0, 0)
        self.controlView?.layer?.shadowRadius = 20
    }
}
