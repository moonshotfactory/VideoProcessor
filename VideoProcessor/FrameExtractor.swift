//
//  FrameExtractor.swift
//  VideoProcessor
//
//  Created by Madhav Jha on 11/20/18.
//  Copyright © 2018 Madhav Jha. All rights reserved.
//

import AVFoundation

class FrameExtractor : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var permissionGranted = false
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    private func defaultCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            return device
        } else {
            return nil
        }
    }
    
    private func configureSession() {
        guard permissionGranted else { return }
        guard let captureDevice = defaultCamera() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
    }
    
    func getPermissionGranted() -> Bool {
        return permissionGranted
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Got a frame!")
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
