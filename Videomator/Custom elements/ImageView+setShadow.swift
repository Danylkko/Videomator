//
//  ImageView+setShadow.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 18.07.2022.
//

import Foundation

extension NSImageView {
    public func setShadow() {
        self.shadow = NSShadow()
        self.layer?.shadowOpacity = 1.0
        self.layer?.shadowColor = NSColor.black.cgColor
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 10
    }
}
