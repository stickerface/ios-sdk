import UIKit
import AVFoundation

protocol SFCameraDelegate: AnyObject {
    func camera(_ camera: SFCamera, faceDidDetect frame: CGRect)
    func cameraFacesDidNotDetect(_ camera: SFCamera)
    func cameraFacesSmallDetect(_ camera: SFCamera)
    func camera(_ camera: SFCamera, photoDidTake image: Data)
}


class SFCamera: NSObject {
    var session = AVCaptureSession()
    lazy var sessionQueue = DispatchQueue(label: "session queue", attributes: [])
    
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoDevice: AVCaptureDevice?
    var movieFileOutput: AVCaptureVideoDataOutput?
    var photoFileOutput: AVCapturePhotoOutput?
    
    public var previewLayer: SFCameraPreview!
    
    weak var delegate: SFCameraDelegate?
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])
    
    override init() {
        super.init()
        
        previewLayer = SFCameraPreview()
        previewLayer.clipsToBounds = true
        previewLayer.session = session
        
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        configureVideoInput()
        configureVideoOutput()
        configurePhotoOutput()
        
        session.commitConfiguration()
    }
    
    func configureVideoInput() {
        videoDevice =  AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first
        
        if let device = videoDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                    if device.isSmoothAutoFocusSupported {
                        device.isSmoothAutoFocusEnabled = true
                    }
                }
                
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                }
                
                if device.isLowLightBoostSupported {
                    device.automaticallyEnablesLowLightBoostWhenAvailable = true
                }
                
                device.unlockForConfiguration()
            } catch {
                print("[Camera]: Error locking configuration")
            }
            
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    print("[Camera]: Could not add video device input to the session")
                    session.commitConfiguration()
                    return
                }
            } catch {
                print("[Camera]: Could not create video device input: \(error)")
                session.commitConfiguration()
                return
            }
        }
    }
    
    func configureVideoOutput() {
        let movieFileOutput = AVCaptureVideoDataOutput()
        
        if session.canAddOutput(movieFileOutput) {
            self.session.addOutput(movieFileOutput)
            if let connection = movieFileOutput.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            movieFileOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            self.movieFileOutput = movieFileOutput
        }
    }
    
    func configurePhotoOutput() {
        let photoFileOutput = AVCapturePhotoOutput()
        
        if session.canAddOutput(photoFileOutput) {
            self.session.addOutput(photoFileOutput)
            self.photoFileOutput = photoFileOutput
        }
    }
    
    func videoBox(frameSize: CGSize, apertureSize: CGSize) -> CGRect {
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = frameSize.width / frameSize.height
        
        var size = CGSize.zero
        
        if viewRatio > apertureRatio {
            size.width = frameSize.width
            size.height = apertureSize.width * (frameSize.width / apertureSize.height)
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width)
            size.height = frameSize.height
        }
        
        var videoBox = CGRect(origin: .zero, size: size)
        
        if size.width < frameSize.width {
            videoBox.origin.x = (frameSize.width - size.width) / 2.0
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2.0
        }
        
        if size.height < frameSize.height {
            videoBox.origin.y = (frameSize.height - size.height) / 2.0
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2.0
        }
        
        return videoBox
    }
    
    func calculateFaceRect(facePosition: CGPoint, faceBounds: CGRect, clearAperture: CGRect) -> CGRect {
        var parentFrameSize: CGSize!
        DispatchQueue.main.sync {
            parentFrameSize = previewLayer!.frame.size
        }
        let previewBox = videoBox(frameSize: parentFrameSize, apertureSize: clearAperture.size)
        
        var faceRect = faceBounds
        
        swap(&faceRect.size.width, &faceRect.size.height)
        swap(&faceRect.origin.x, &faceRect.origin.y)
        
        let widthScaleBy = previewBox.size.width / clearAperture.size.height
        let heightScaleBy = previewBox.size.height / clearAperture.size.width
        
        faceRect.size.width *= widthScaleBy
        faceRect.size.height *= heightScaleBy
        faceRect.origin.x *= widthScaleBy
        faceRect.origin.y *= heightScaleBy
        
        faceRect = faceRect.offsetBy(dx: 0.0, dy: previewBox.origin.y)
        let frame = CGRect(x: parentFrameSize.width - faceRect.origin.x - faceRect.size.width - previewBox.origin.x / 2.0, y: faceRect.origin.y, width: faceRect.width, height: faceRect.height)
        
        return frame
    }
}

extension SFCamera {
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if #available(macCatalyst 14.0, *) {
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                 kCVPixelBufferWidthKey as String: 160,
                                 kCVPixelBufferHeightKey as String: 160]
            settings.previewPhotoFormat = previewFormat
        }
        self.photoFileOutput?.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension SFCamera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        delegate?.camera(self, photoDidTake: data)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension SFCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        
        let ciImage = CIImage(
            cvImageBuffer: pixelBuffer!,
            options: attachments as? [String : Any]
        )
        
        let options: [String : Any] = [
            CIDetectorImageOrientation: 6,
            CIDetectorSmile: true,
            CIDetectorEyeBlink: true
        ]
        
        let allFeatures = faceDetector?.features(in: ciImage, options: options)
        
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription!, false)
        
        guard let features = allFeatures else { return }
        
        for feature in features {
            if let faceFeature = feature as? CIFaceFeature {
                let faceRect = calculateFaceRect(facePosition: faceFeature.mouthPosition, faceBounds: faceFeature.bounds, clearAperture: cleanAperture)
                
                var minFaceSize: CGFloat = 0
                DispatchQueue.main.sync {
                    minFaceSize = previewLayer!.frame.width * 0.45
                }
                if faceRect.width < minFaceSize || faceRect.height < minFaceSize {
                    self.delegate?.cameraFacesSmallDetect(self)
                } else {
                    self.delegate?.camera(self, faceDidDetect: faceRect)
                }
            }
        }
        
        if features.count == 0 {
            DispatchQueue.main.async {
                self.delegate?.cameraFacesDidNotDetect(self)
            }
        }
    }
    
}
