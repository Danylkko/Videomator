//
//  ViewController.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 08.07.2022.
//

import Cocoa
import AVKit
import AVFoundation

class MainViewController: NSViewController {
    
    //    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak private var videoContainer: NSView!
    @IBOutlet weak private var sliderCell: MyNSSliderCell!
    @IBOutlet weak var imageView: NSImageView!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private static let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!
    
    private var blurer: BlurerWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = AVPlayer(url: MainViewController.url)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = .resizeAspect
        
        self.videoContainer.layer = self.playerLayer
        self.videoContainer.wantsLayer = true
        self.player.play()
        
        Task {
            await self.getPreviews(url: MainViewController.url)
        }
    }
    
    private func getPreviews(url: URL) async {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.maximumSize = CGSize(
            width: self.sliderCell.controlView!.frame.height * 2,
            height: self.sliderCell.controlView!.frame.height
        )
        
        let times = self.getTimeCodes()
        
        generator.generateCGImagesAsynchronously(forTimes: times) { _, image, _, result, _ in
            let newImage = NSImage(cgImage: image!, size: .zero)
            DispatchQueue.main.async {
                self.sliderCell.setPatterns(
                    with: newImage,
                    requiredAmount: times.count
                )
            }
        }
    }
    
    private func getTimeCodes() -> [NSValue] {
        let asset = AVURLAsset(url: MainViewController.url)
        let numberOfFrames = self.sliderCell.controlView!.frame.width / self.sliderCell.controlView!.frame.height
        let duration = CMTimeGetSeconds(asset.duration)
        var times = [NSValue]()
        var k: Double = 0
        
        if numberOfFrames < duration {
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
    
    override func viewDidLayout() {
        super.viewDidLayout()
        //        self.playerLayer.frame = self.videoContainer.frame
    }
    
    @IBAction private func openVideo(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                guard let pbPath = ResourcesManager.shared.pbURL?.path,
                      let tessPath = ResourcesManager.shared.tessURL?.path,
                      let imgPath = ResourcesManager.shared.testImgURL?.path else { return }
                self.blurer = BlurerWrapper(pbPath, tessPath)
                self.blurer?.load(url.path)
                self.blurer?.detect(0)
                self.imageView.image = self.blurer?.buffer()
            }
        }
    }
    
    func imagePreview(from moviePath: URL, in seconds: Double) -> NSImage? {
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 60)
        let asset = AVURLAsset(url: moviePath)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) else {
            return nil
        }
        return NSImage(cgImage: imageRef, size: .zero)
    }
    
}


