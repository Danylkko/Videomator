//
//  VideoManager.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 11.07.2022.
//

import Foundation

public class VideoManager {
    
    private var videoURL: URL
    private var blurer: BlurerWrapper
    
    public var fps: Int {
        self.blurer.getFps()
    }
    
    public var framesCount: Int {
        self.blurer.getFrameCount()
    }
    
    public init(videoURL: URL) {
        self.videoURL = videoURL
        guard let pbPath = ResourcesManager.shared.pbURL?.path,
              let tessPath = ResourcesManager.shared.tessURL?.path else {
            fatalError("frozen_east_text_dection.pb or eng.traineddata not found")
        }
        self.blurer = BlurerWrapper(pbPath, tessPath)
        self.blurer.load(videoURL.path)
        self.blurer.startRender()
    }
    
    private var rendered = [NSImage]()
    
    public func render(onUpdate: @escaping ([NSImage]) -> Void) {
        self.createStream()
        Task(priority: .high) {
            while self.rendered.count < self.blurer.getFrameCount() {
                if let image = self.buffer() {
                    self.rendered.append(image)
                    print("\(self.rendered.count) frames of \(self.framesCount), fps: \(self.fps)")
                }
                try await Task.sleep(nanoseconds: UInt64((1_000_000_000 / self.fps)))
                //400_000_000_000 for large video
            }
            self.blurer.pauseStream()
            
            onUpdate(self.rendered)
        }
    }
    
    public func play(imageSet: [NSImage], onUpdate: @escaping (NSImage) -> Void) {
        Task(priority: .userInitiated) {
            self.blurer.createStream()
            self.blurer.playStream(0)
            while true {
                for image in imageSet {
                    DispatchQueue.main.async {
                        onUpdate(image)
                    }
                    try await Task.sleep(nanoseconds: UInt64((1_000_000_000 / self.fps)))
                }
            }
        }
    }
    
    public func createStream() {
        self.blurer.createStream()
        self.blurer.playStream(self.fps)
    }
    
    public func buffer() -> NSImage? {
        self.blurer.streamBuffer() ?? nil
    }
    
    public func saveRendered(in directory: URL, as name: String) {
        var savePath = directory
        savePath.appendPathComponent(name)
        self.blurer.saveRendered(savePath.path)
    }
    
}
