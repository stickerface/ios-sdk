import UIKit
import AVFoundation

public enum CameraVideoGravity {
    case resize
    case resizeAspect
    case resizeAspectFill
}

class SFCameraPreview: UIView {
    
    // MARK: - properties
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewlayer = layer as! AVCaptureVideoPreviewLayer
        switch gravity {
        case .resize:
            previewlayer.videoGravity = .resize
        case .resizeAspect:
            previewlayer.videoGravity = .resizeAspect
        case .resizeAspectFill:
            previewlayer.videoGravity = .resizeAspectFill
        }
        return previewlayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    // MARK: - Overrides
    
    private var gravity: CameraVideoGravity = .resizeAspectFill
    
    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
