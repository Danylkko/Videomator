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
    private var manager: VideoManager?
    private var blurer: BlurerWrapper?
    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func configureUI(for video: URL) {
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        layer.backgroundColor = NSColor.blue.cgColor
        self.imageView.wantsLayer = true
        self.imageView.layer = layer
        
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
    
    @IBAction func export(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                self.manager?.saveRendered(in: url, as: "blurred.mp4")
            }
        }
        
    }
    
}
