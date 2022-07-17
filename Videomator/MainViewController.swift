//
//  ViewController.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 08.07.2022.
//

import Cocoa
import RxSwift
import RxCocoa
import AVKit
import AVFoundation

class MainViewController: NSViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var sliderCell: MyNSSliderCell!
    @IBOutlet weak var timelineSlider: NSSlider!
    @IBOutlet weak var backgroundEffect: NSVisualEffectView!
    
    //MARK: - Other properties
    private var manager: VideoManager?
    private var blurer: BlurerWrapper?
    
    private let bag = DisposeBag()
    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        self.view.wantsLayer = true
        self.view.layer = layer
        
        self.backgroundEffect.blendingMode = .behindWindow
        self.sliderCell.doubleValue = 0.0
        self.sliderCell.maxValue = 100.0
        self.sliderCell.isEnabled = false
    }
    
    private func bindUI() {
        let timeline = self.timelineSlider.rx.value.changed.share()
        
        timeline
            .debounce(.milliseconds(20), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.manager?.getImageForTime(value: value) { image in
                    DispatchQueue.main.async {
                        print(value)
                        self?.view.layer?.contents = image
                        self?.imageView.layer?.contents = image
                    }
                }
            }).disposed(by: bag)

        timeline
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.manager?.render(value: value) { image in
                    DispatchQueue.main.async {
                        self?.imageView.layer?.contents = image
                    }
                }
            }).disposed(by: bag)
    }
    
    private func configureUI(for url: URL, onComplete: @escaping () -> Void) {
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        self.imageView.wantsLayer = true
        self.imageView.layer = layer
        self.backgroundEffect.blendingMode = .withinWindow
        self.sliderCell.isContinuous = true
        self.sliderCell.doubleValue = 0
        self.sliderCell.completionHandler = onComplete
        self.sliderCell.videoURL = url
        self.sliderCell.setShadow()
    }
    
    @IBAction private func openVideo(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                self.configureUI(for: url) {
                    self.sliderCell.isEnabled = true
                    self.manager = VideoManager(videoURL: url)
                    self.manager?.getImageForTime(value: 0) { image in
                        DispatchQueue.main.async {
                            self.view.layer?.contents = image
                            self.imageView.layer?.contents = image
                            self.timelineSlider.needsDisplay = true
                        }
                    }
                    self.bindUI()
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
