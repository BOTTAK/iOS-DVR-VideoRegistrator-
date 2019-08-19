//
//  FoundationViewController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 04/08/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation

typealias ImageWithName = (UIImage, String)

class FoundationViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    private var videoDevice: AVCaptureDevice!
    private let captureSession = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    @IBOutlet weak var previewView: VideoOutputView!
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureDevice()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            
            self.movieOutput.stopRecording()
            self.captureSession.stopRunning()
            print("timer")
        }
    }
    
    // MARK: Capture session setup
    private func setupCaptureDevice() {
        
        captureSession.beginConfiguration()
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                              for: .video, position: .back)
        
        setupCaptureInput()
        setupCaptureOutput()
        
        captureSession.commitConfiguration()
        previewView.videoPreviewLayer.session = captureSession
        captureSession.startRunning()
        movieOutput.startRecording(to: FileManager.createNewFilePath(fileName: "testingcapture"),
                                   recordingDelegate: self)
    }
    
    private func setupCaptureInput() {
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
    }
    
    private func setupCaptureOutput() {
        
        guard captureSession.canAddOutput(movieOutput) else { fatalError() }
        captureSession.sessionPreset = .hd1280x720
        captureSession.addOutput(movieOutput)
    }
    
}

extension FoundationViewController {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("start")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL)
        
        //input file
        let asset = AVAsset.init(url: outputFileURL)
        print (asset)
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        //input clip
        let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        //adding the image layer
        let imglogo = UIImage(named: "3454235-727x522")
        let watermarkLayer = CALayer()
        watermarkLayer.contents = imglogo?.cgImage
        watermarkLayer.frame = CGRect(x: 5, y: 25 ,width: 57, height: 57)
        watermarkLayer.opacity = 0.85
        
        let textLayer = CATextLayer()
        textLayer.string = "TEXTTEXTTEXT123"
        textLayer.foregroundColor = UIColor.red.cgColor
        textLayer.font = UIFont.systemFont(ofSize: 50)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.bounds = CGRect(x: previewView.center.x, y: view.center.y, width: 20, height: 20)
        
        let videoSize = clipVideoTrack.naturalSize
        let parentlayer = CALayer()
        let videoLayer = CALayer()
        
        parentlayer.frame = CGRect(x: 0, y: 0, width: videoSize.height, height: videoSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.height, height: videoSize.height)
        parentlayer.addSublayer(videoLayer)
        parentlayer.addSublayer(watermarkLayer)
        parentlayer.addSublayer(textLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: previewView.frame.width, height: previewView.frame.height) //change it as per your needs.
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderScale = 1.0
        
        //Magic line for adding watermark to the video
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(60, preferredTimescale: 30))
        
        //rotate to potrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let t1 = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
        let t2: CGAffineTransform = t1.rotated(by: .pi/2)
        let finalTransform: CGAffineTransform = t2
        transformer.setTransform(finalTransform, at: CMTime.zero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let exporter = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        exporter?.outputFileType = AVFileType.mp4
        exporter?.outputURL = FileManager.createNewFilePath(fileName: "testingtext")
        exporter?.videoComposition = videoComposition
        
        
        
        exporter!.exportAsynchronously(completionHandler: {() -> Void in
            switch exporter!.status {
            case .failed:
                print(exporter!.error ?? "No error")
            case .cancelled:
                let error = NSError(domain: "VideoApp", code: 00, userInfo: ["Message": "Export cancelled"])
                print(error.localizedDescription)
            case .completed:
                print("Successful! \(String(describing: exporter!.outputURL))")
                UISaveVideoAtPathToSavedPhotosAlbum(exporter!.outputURL!.path,
                                                    self,
                                                    #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                    nil)
            default:
                fatalError()
            }
        })
        
        
        
//        let asset = AVURLAsset(url: outputFileURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
//        let composition = AVMutableComposition()
//        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        let clipVideoTrack = asset.tracks(withMediaType: .video)[0]
//
//        do {
//            try compositionVideoTrack?.insertTimeRange(CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 600), duration: asset.duration),
//                                                       of: clipVideoTrack, at: CMTime(seconds: 0, preferredTimescale: 600))
//        } catch {
//            print(error)
//        }
//
//        compositionVideoTrack?.preferredTransform = asset.tracks(withMediaType: .video)[0].preferredTransform
//
//        let image = UIImage(named: "3454235-727x522")
//        let layer = CALayer()
//        layer.contents = image?.cgImage
//        layer.frame = CGRect(x: 5, y: 25, width: 58, height: 58)
//        layer.opacity = 0.65
//
//        let parentLayer = CALayer()
//        let videoLayer = CALayer()
//
//        parentLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
//        videoLayer.frame = parentLayer.frame
//
//        parentLayer.addSublayer(videoLayer)
//        parentLayer.addSublayer(layer)
//
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.renderSize =
        
        
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        
        let alert = error == nil
            ? UIAlertController(title: "Успешно", message: "Видео сохранено", preferredStyle: .alert)
            : UIAlertController(title: "Ошибка", message: error?.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: { _ in
//            self.startRecording()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

