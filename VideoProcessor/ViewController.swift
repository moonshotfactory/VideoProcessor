//
//  ViewController.swift
//  VideoProcessor
//
//  Created by Madhav Jha on 11/20/18.
//  Copyright © 2018 Madhav Jha. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FrameExtractorDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var frameExtractor : FrameExtractor!

    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        let permissionGranted = frameExtractor.getPermissionGranted()
        print(permissionGranted)
    }
    
    func captured(image: UIImage) {
        imageView.image = image
    }


}

