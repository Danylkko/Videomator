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
        let layer = CALayer()
        self.view.wantsLayer = true
        self.view.layer = layer
    }
    
    private func configureUI(for url: URL, onComplete: @escaping () -> Void) {
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        self.imageView.wantsLayer = true
        self.imageView.layer = layer
        self.sliderCell.setShadow()
        self.sliderCell.doubleValue = 0.0
        self.sliderCell.isEnabled = false
        self.sliderCell.completionHandler = onComplete
        self.sliderCell.videoURL = url
    }
    
    @IBAction private func openVideo(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                self.configureUI(for: url) {
                    self.sliderCell.isEnabled = true
                    self.manager = VideoManager(videoURL: url)
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
