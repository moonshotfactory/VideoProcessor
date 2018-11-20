//
//  FrameExtractor.swift
//  VideoProcessor
//
//  Created by Madhav Jha on 11/20/18.
//  Copyright © 2018 Madhav Jha. All rights reserved.
//

import AVFoundation

class FrameExtractor {
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var permissionGranted = false
    
    init() {
        checkPermission()
    }
    
    func getPermissionGranted() -> Bool {
        return permissionGranted
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
        
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self](granted) in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
        
    }
    
}
