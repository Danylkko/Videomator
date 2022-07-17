//
//  ResourcesManager.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 10.07.2022.
//

import Foundation

public struct ResourcesManager {
    
    public static let shared = ResourcesManager()
    
    private let mainBundle = Bundle.main
    
    public var pbURL: URL? {
        self.mainBundle.url(forResource: "frozen_inference_graph", withExtension: "pb")
    }
    
    public var pbTxtURL: URL? {
        self.mainBundle.url(forResource: "frozen_inference", withExtension: "pbtxt")
    }
    
    public var tessURL: URL? {
        self.mainBundle.resourceURL
    }
    
    public var testImgURL: URL? {
        self.mainBundle.url(forResource: "james-deane-drifting-s15", withExtension: "jpg")
    }
    
}
