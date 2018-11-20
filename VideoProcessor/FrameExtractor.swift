//
//  FrameExtractor.swift
//  VideoProcessor
//
//  Created by Madhav Jha on 11/20/18.
//  Copyright © 2018 Madhav Jha. All rights reserved.
//

import AVFoundation
import UIKit


protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class FrameExtractor : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var delegate: FrameExtractorDelegate?
    
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var permissionGranted = false
    
    private let context = CIContext()

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
//        print("Got a frame!")
        DispatchQueue.main.async { [unowned self] in
            guard let uiImage = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
            self.delegate?.captured(image: uiImage)
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
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
