//
//  ResourcesManager.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 10.07.2022.
//

import Foundation

struct ResourcesManager {
    
    public static let shared = ResourcesManager()
    
    let mainBundle = Bundle.main
    
    var pbURL: URL? {
        self.mainBundle.url(forResource: "frozen_east_text_detection", withExtension: "pb")
    }
    
    var tessURL: URL? {
        self.mainBundle.resourceURL
    }
    
    var testImgURL: URL? {
        self.mainBundle.url(forResource: "james-deane-drifting-s15", withExtension: "jpg")
    }
    
}
