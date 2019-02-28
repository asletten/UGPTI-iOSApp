//
//  PhotoCaptureHelper.swift
//  Road Capture
//
//  Created by Aaron Sletten on 2/27/19.
//  Copyright © 2019 Aaron Sletten. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoCaptureHelper: NSObject, AVCapturePhotoCaptureDelegate {

    //Set Up Camera Session
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraView: UIView?
    
    //structure to hold images
    var imagesArray = [UIImage?]()
    
    var triggerFunction : ()->Void = {}
    
    //init
    init(view: UIView, cameraView: UIView) {
        super.init()
        
        //set properties
        self.cameraView = cameraView
        
        //setup capture session
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer(view: view)
        startRunningCaptureSession()
    }
    
    //fuctions
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back {
                backCamera =  device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            
            photoOutput = AVCapturePhotoOutput()
        photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer(view: UIView) {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        cameraPreviewLayer?.frame = view.frame
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            imagesArray.append(image)
            triggerFunction()
        }
    }
    
    //take photo
    func takePhoto(triggerFunction : @escaping ()->Void){
        self.triggerFunction = triggerFunction
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings , delegate: self)
    }
}