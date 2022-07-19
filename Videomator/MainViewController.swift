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
    @IBOutlet weak var previewSpinner: NSProgressIndicator!
    @IBOutlet weak var renderIndicator: NSProgressIndicator!
    @IBOutlet weak var renderLabel: NSTextField!
    @IBOutlet weak var backgroundEffect: NSVisualEffectView!
    
    
    //MARK: - Other properties
    private var manager: VideoManager?
    private var blurer: BlurerWrapper?
    
    private let bag = DisposeBag()
    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableProgress(false)
        self.configureSuperView()
        self.configureImageView()
        
        
        self.previewSpinner.isHidden = true
        self.backgroundEffect.blendingMode = .behindWindow
        self.sliderCell.doubleValue = 0.0
        self.sliderCell.maxValue = 100.0
        self.renderLabel.stringValue = "0% rendered"
        self.renderIndicator.doubleValue = 0
        self.sliderCell.isEnabled = false
    }
    
    private func bindUI() {
        let timeline = self.timelineSlider.rx.value.changed.share()
        
        timeline
            .debounce(.milliseconds(15), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.manager?.getImageForTime(value: value) { image in
                    DispatchQueue.main.async {
                        
                        self?.view.layer?.contents = image
                        self?.imageView.layer?.contents = image
                    }
                }
            }).disposed(by: bag)
        
        timeline
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.enableSpinner(true)
                self?.manager?.render(value: value) { image in
                    DispatchQueue.main.async {
                        self?.imageView.layer?.contents = image
                        self?.enableSpinner(false)
                    }
                }
            }).disposed(by: bag)
    }
    
    private func configureSuperView() {
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        self.view.wantsLayer = true
        self.view.layer = layer
    }
    
    private func configureImageView() {
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        layer.cornerRadius = 5
        self.imageView.wantsLayer = true
        self.imageView.layer = layer
    }
    
    private func configureUI(for url: URL, onComplete: @escaping () -> Void) {
        self.backgroundEffect.blendingMode = .withinWindow
        
        self.sliderCell.isContinuous = true
        self.sliderCell.doubleValue = 0
        self.sliderCell.completionHandler = onComplete
        self.sliderCell.videoURL = url
        self.sliderCell.setShadow()
        
    }
    
    private func enableProgress(_ status: Bool) {
        self.renderLabel.isHidden = !status
        self.renderIndicator.isHidden = !status
    }
    
    private func enableSpinner(_ status: Bool) {
        self.previewSpinner.isHidden = !status
        status ? self.previewSpinner.startAnimation(nil) : self.previewSpinner.stopAnimation(nil)
    }
    
    @IBAction private func openVideo(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                self.configureUI(for: url) { [weak self] in
                    self?.sliderCell.isEnabled = true
                    if self?.manager == nil {
                        self?.manager = VideoManager(videoURL: url)
                    } else {
                        self?.manager?.reloadVideo(url: url)
                    }
                    self?.enableSpinner(true)
                    self?.manager?.render(value: 0) { image in
                        DispatchQueue.main.async {
                            self?.view.layer?.contents = image
                            self?.imageView.layer?.contents = image
                            self?.timelineSlider.needsDisplay = true
                            self?.enableSpinner(false)
                            self?.enableProgress(true)
                        }
                    }
                    self?.manager?.bindProgress { value in
                        DispatchQueue.main.async {
                            self?.renderLabel.stringValue = "\(value)% rendered"
                            self?.renderIndicator.doubleValue = Double(value)
                        }
                    }
                    self?.bindUI()
                }
            }
        }
    }
    
    @IBAction func export(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.title = "Choose the directory to save rendered video"
        savePanel.allowedContentTypes = [.mpeg4Movie, .avi]
        
        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                DispatchQueue.global(qos: .background).async {
                    self.manager?.saveRendered(in: url)
                }
            }
        }
        
    }
    
}
