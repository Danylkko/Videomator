//
//  ViewController.swift
//  Videomator
//
//  Created by Danylo Litvinchuk on 08.07.2022.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var imageView: NSImageView!
    
    private var blurer: BlurerWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pbPath = ResourcesManager.shared.pbURL?.path,
                let tessPath = ResourcesManager.shared.tessURL?.path,
              let imgPath = ResourcesManager.shared.testImgURL?.path else { return }
        self.blurer = BlurerWrapper(pbPath, tessPath)
        self.blurer?.load(imgPath)
        self.blurer?.detect(0)
        self.imageView.image = blurer?.buffer()
    }

}

