//
//  MainController.swift
//  Not Hotdog
//
//  Created by Charles Kenney on 11/23/17.
//  Copyright © 2017 Charles Kenney. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class MainController: UIViewController {
    
    var session: AVCaptureSession?
    
    var output: AVCapturePhotoOutput?
    
    var preview: AVCaptureVideoPreviewLayer?
    
    let captureSettings: AVCapturePhotoSettings = {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        return settings
    }()
    
    lazy var captureButton: UIButton? = {
        let button = UIButton()
        button.frame = CGRect(x: view.center.x - 30, y: view.frame.height - 75, width: 60, height: 60)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.clipsToBounds = true
        button.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCaptureSession()
        setupPreview()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session?.stopRunning()
        preview?.removeFromSuperlayer()
        session = nil
    }
    
}


// MARK: - View Preperations

fileprivate extension MainController {
    
    func setupPreview() {
        guard let preview = self.preview else { return }
        preview.frame = view.frame
        view.layer.insertSublayer(preview, at: 0)
    }
    
    func setupCaptureButton() {
        guard let captureButton = self.captureButton else { return }
        view.addSubview(captureButton)
        captureButton.addTarget(self, action: #selector(handlePhotoCaptured(_:)), for: .touchUpInside)
    }
    
}


// MARK: - Actions

@objc extension MainController {
    
    func handlePhotoCaptured(_ sender: Any?) {
        output?.capturePhoto(with: captureSettings, delegate: self)
    }
    
}


// MARK: - AVCapturePhotoCaptureDelegate

extension MainController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func setupCaptureSession() {
        // get devices
        session = AVCaptureSession()
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back
        ).devices
        // setup input
        do {
            guard let device = devices.first else { fatalError() }
            let input = try AVCaptureDeviceInput(device: device)
            session?.addInput(input)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        // setup output
        output = AVCapturePhotoOutput()
        session?.addOutput(output!)
        // init preview
        preview = AVCaptureVideoPreviewLayer(session: session!)
        session?.startRunning()
    }
    
}


// MARK: - AVCapturePhotoCaptureDelegate

extension MainController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: data)
        let resultController = ResultController()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        present(resultController, animated: true, completion: {
            resultController.image = image
        })
    }
    
}

