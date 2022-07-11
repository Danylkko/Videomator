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
    @IBOutlet weak private var videoContainer: NSView!
    @IBOutlet weak private var sliderCell: MyNSSliderCell!
    
    //MARK: - Other properties
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private static let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!
    private var blurer: BlurerWrapper?
    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.player = AVPlayer(url: MainViewController.url)
//        self.playerLayer = AVPlayerLayer(player: self.player)
//        self.playerLayer.videoGravity = .resizeAspect
//
//        self.videoContainer.layer = self.playerLayer
//        self.videoContainer.wantsLayer = true
//        self.player.play()
        self.sliderCell.doubleValue = 0.0
        self.sliderCell.isEnabled = false
        self.sliderCell.completionHandler = {
            self.sliderCell.isEnabled = true
        }
        self.sliderCell.videoURL = MainViewController.url
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
                      let _ = ResourcesManager.shared.testImgURL?.path else { return }
                self.blurer = BlurerWrapper(pbPath, tessPath)
                self.blurer?.load(url.path)
                
//                print("fps: ", self.blurer?.getFps())
//                self.blurer?.detect(0)
            }
        }
    }
    
}


