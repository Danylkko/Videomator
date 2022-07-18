//
//  VideoManager.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 11.07.2022.
//

import Foundation
import AVFoundation
import AVKit

public class VideoManager {
    
    private var videoURL: URL {
        didSet {
            self.asset = AVURLAsset(url: self.videoURL)
            self.generator = AVAssetImageGenerator(asset: self.asset)
            self.generator.requestedTimeToleranceBefore = .zero
            self.generator.requestedTimeToleranceAfter = .zero
        }
    }
    private var blurer: BlurerWrapper
    private lazy var asset = AVURLAsset(url: self.videoURL)
    private lazy var generator = AVAssetImageGenerator(asset: self.asset)
    private var binder: DispatchWorkItem?
    private var progressBinder = DispatchQueue(label: "progress")
    
    public var fps: Int {
        self.blurer.getFps()
    }
    
    public var framesCount: Int {
        self.blurer.getFrameCount()
    }
    
    public init(videoURL: URL) {
        self.videoURL = videoURL
        guard let pbPath = ResourcesManager.shared.pbURL?.path,
              let pbTxtPath = ResourcesManager.shared.pbTxtURL?.path,
              let tessPath = ResourcesManager.shared.tessURL?.path else {
            fatalError("frozen_east_text_dection.pb or eng.traineddata not found")
        }
        self.blurer = BlurerWrapper(pbPath, pbTxtPath, tessPath)
        self.blurer.load(videoURL.path)
        self.generator.requestedTimeToleranceBefore = .zero
        self.generator.requestedTimeToleranceAfter = .zero
        self.blurer.startRender()
    }
    
    public func bindProgress(onUpdate: @escaping (Int) -> Void) {
        self.binder?.cancel()
        self.binder = DispatchWorkItem {
            while true {
                let progress = self.blurer.numberOfRendered() * 100
                onUpdate(Int(progress.rounded()))
                sleep(3)
            }
        }
        self.progressBinder.async(execute: binder!)
    }
    
    
    
    public func reloadVideo(url: URL) {
        self.videoURL = url
        self.blurer.load(url.path)
        self.blurer.startRender()
    }
    
    public func render(value: Double, onUpdate: @escaping (NSImage) -> Void) {
        var frameIndex = Int(Float(value) * Float(self.blurer.getFrameCount()) / 100)
        
        if frameIndex >= self.blurer.getFrameCount() {
            frameIndex = self.blurer.getFrameCount() - 2
        } else if frameIndex < 1 {
            frameIndex = 1
        }
        
        self.blurer.createStream(frameIndex)
        print("stream start playing at frame: \(frameIndex)")
        DispatchQueue.global(qos: .userInteractive).async {
            guard let preview = self.blurer.streamBuffer() else { return }
            onUpdate(preview)
        }
    }
    
    public func getImageForTime(value: Double, onComplete: @escaping (NSImage) -> Void) {
        let timing = TimingManager.getTimingFor(currentValue: value, of: self.asset.duration.seconds)
        self.generator.generateCGImagesAsynchronously(forTimes: timing)
        { _, image, _, result, _ in
            guard let cgImage = image else { return }
            let frame = NSImage(cgImage: cgImage, size: .zero)
            onComplete(frame)
        }
    }
    
    public func saveRendered(in directory: URL) {
        self.blurer.saveRendered(directory.path)
    }
    
}
