//
//  ViewController.swift
//  VideoProcessor
//
//  Created by Madhav Jha on 11/20/18.
//  Copyright © 2018 Madhav Jha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var frameExtractor : FrameExtractor!

    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        let permissionGranted = frameExtractor.getPermissionGranted()
        print(permissionGranted)
        let previewLayer = frameExtractor.getPreviewLayer()
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }


}

