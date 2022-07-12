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
    
    //MARK: - IBOutlets
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var sliderCell: MyNSSliderCell!
    
    //MARK: - Other properties
    //    private var player: AVPlayer!
    //    private var playerLayer: AVPlayerLayer!
    private var manager: VideoManager?
    private static let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!
    private var blurer: BlurerWrapper?
    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func configureUI(for video: URL) {
        //        let layer = CALayer()
        //        layer.backgroundColor = NSColor.green.cgColor
        //        self.imageView.wantsLayer = true
        //        self.imageView.layer = layer
        self.sliderCell.doubleValue = 0.0
        self.sliderCell.isEnabled = false
        self.sliderCell.completionHandler = {
            self.sliderCell.isEnabled = true
            self.manager = VideoManager(videoURL: video)
        }
        self.sliderCell.videoURL = video
    }
    
    @IBAction private func openVideo(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        self.imageView.wantsLayer = true
        self.imageView.layer = layer
        
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                self.configureUI(for: url)
                self.manager = VideoManager(videoURL: url)
                self.manager?.render { images in
                    self.manager?.play(imageSet: images) { image in
                        self.imageView.layer?.contents = image
                    }
                }
            }
        }
    }
    
}
