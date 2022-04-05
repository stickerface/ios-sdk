import UIKit
import AVFoundation

class GenerateAvatarViewController: ViewController<GenerateAvatarView> {
    
    private var layers: String?
    private var shouldAutoOpenCamera: Bool = true
    private var cameraOpenCount: Int = 0
    private var isAvatarGenerated: Bool = false
    private var faceDetected = false
    private var smallFace = false
    private var faceDetectTimer: Timer?
    private var locked = false
    private var uploadTask: URLSessionDataTask?
    private var deiniting = false
    
    private let player: AVPlayer = {
        let path = Bundle.resourceBundle.path(forResource: "onboardingAvatar", ofType: "mp4")!
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.linesRoundRotateAnimationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCamera)))
        mainView.allowButton.addTarget(self, action: #selector(allowButtonTapped), for: .touchUpInside)
        mainView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        mainView.camera.delegate = self
        
        mainView.onboardingAvatarVideoView.playerLayer.player = player
        
        play()
        bindEvents()
        updateButtonTitles()
    }
    
    // MARK: - Private Actions
    
    @objc private func bindEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(play), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc private func close() {
        UIView.animate(withDuration: 0.3) {
            self.mainView.onboardingAvatarVideoView.alpha = 0
            self.mainView.avatarPlaceholderView.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if self?.shouldAutoOpenCamera == true {
                self?.checkCameraAccess()
            }
        }
        
        removeEvents()
    }
    
    @objc private func pause() {
        player.pause()
    }
    
    @objc private func play() {
        mainView.onboardingAvatarVideoView.alpha = 1
        mainView.avatarPlaceholderView.alpha = 0
        player.play()
        mainView.linesRoundRotateAnimationView.update(lineType: .dot)
        
        UIView.animate(withDuration: 0.3, delay: 1.15, options: .curveEaseOut) {
            self.mainView.linesRoundRotateAnimationView.update(lineType: .line)
        }
    }
    
    @objc private func openCamera() {
        showCameraController()
    }
    
    @objc private func continueButtonTapped() {
        if isAvatarGenerated {
            showCameraController()
        } else {
            shouldAutoOpenCamera = false
            layers = ImageLoader.defaultLayers
            close()
            isAvatarGenerated = true
            nextStep()
        }
    }
    
    @objc private func allowButtonTapped() {
        if isAvatarGenerated {
            nextStep()
        } else {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            if status == .authorized {
                close()
                showCameraController()
            } else {
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func removeEvents() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func checkCameraAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] response in
                if response {
                    DispatchQueue.main.async { [weak self] in
                        self?.showCameraController()
                    }
                }
            }
        } else if status == .authorized {
            showCameraController()
        }
        
        updateButtonTitles()
    }
    
    private func showCameraController() {
        cameraOpenCount += 1
        
        //        StickerFace.shared.tintColor = .sfAccentBrand
//        let controller = StickerFace.shared.getCameraViewController()
        //        controller.copyrightVisible = false
        //        controller.delegate = self
        initCamera()
        //        present(controller, animated: true)
    }
    
    private func updateAvatar() {
        mainView.avatarPlaceholderView.alpha = 0
        mainView.linesRoundRotateAnimationView.alpha = 0
        mainView.descriptionLabel.alpha = 0
        isAvatarGenerated = true
        
        let side = mainView.avatarImageView.bounds.size.height
        ImageLoader.setAvatar(with: layers, for: mainView.avatarImageView, side: side, cornerRadius: side/2)
    }
    
    private func nextStep() {
        guard let layers = layers else { return }
        
        let vc = StickerFaceViewController(type: .editor, layers: layers)
        vc.modalPresentationStyle = .fullScreen
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateButtonTitles() {
        let continueTitle: String
        let allowTitle: String
        
        if isAvatarGenerated {
            continueTitle = "setupAvatarGenerateNewTitle".libraryLocalized
            allowTitle = "commonContinue".libraryLocalized
        } else {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            allowTitle = status == .authorized ?
            "setupAvatarGenerateTitle".libraryLocalized :
            "setupAvatarAllowTitle".libraryLocalized
            
            continueTitle = "setupAvatarContinueTitle".libraryLocalized
        }
        
        mainView.allowButton.setTitle(allowTitle, for: .normal)
        mainView.continueButton.setTitle(continueTitle, for: .normal)
    }
    
    func initCamera() {
        mainView.camera.previewLayer.alpha = 1
        
        //        DispatchQueue.global(qos: .background).async {
        self.mainView.camera.session.startRunning()
        //        }
    }
    
    @objc func hasFaceDidChange() {
        if faceDetected {
            //            effectsController.setState(true)
            
            faceDetectTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(takePhoto), userInfo: nil, repeats: false)
        } else if smallFace {
            //            infoLabel = .smallFace
        } else {
            //            infoLabel = .noFace
        }
        
        //        self.effectsController.setState(faceDetected)
    }
    
    @objc func takePhoto() {
        locked = true
        mainView.camera.capturePhoto()
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func upload(_ image: Data) {
        let resizedImage = resizeImage(image: UIImage(data: image, scale:1.0)!, targetSize: CGSize(width: 600, height: 600))
        
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.9)
        let urlString = "https://sticker.face.cat/api/process?platform=ios"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let mutableURLRequest = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        
        mutableURLRequest.httpMethod = "POST"
        
        let boundaryConstant = "----------------12345";
        let contentType = "multipart/form-data;boundary=" + boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"filename.jpg\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: image\r\n\r\n".data(using: .utf8)!)
        uploadData.append(imageData!)
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        mutableURLRequest.httpBody = uploadData as Data
        
        uploadTask = session.dataTask(with: mutableURLRequest as URLRequest, completionHandler: { [weak self] data, _, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
//                self.forceClose()
                
            } else if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//                        self.forceClose()
                        
                        return
                    }
                    
                    guard json["error"] == nil else {
//                        self.forceClose()
                        
                        return
                    }
                    
                    var stickers = [String]()
                    if let stickersRaw = json["stickers"] as? [Int] {
                        for i in stickersRaw {
                            stickers.append("\(i)")
                        }
                    }
                    
                    if let layers = json["model"] as? String {
                        DispatchQueue.main.async {
//                            self.delegate?.sfCameraViewController(self, didGenerate: layers, stickers: stickers)
//                            self.dismiss(animated: true)
                            self.mainView.camera.previewLayer.alpha = 0
                            self.layers = layers
                            self.updateAvatar()
                            self.updateButtonTitles()
                        }
                    }
                    
                } catch {
//                    self.forceClose()
                }
            }
            
        })
        
        uploadTask?.resume()
    }
}

// MARK: - SFCameraViewControllerDelegate
//extension GenerateAvatarViewController: SFCameraViewControllerDelegate {
//
//    func sfCameraViewController(_ controller: SFCameraViewController, didGenerate layers: String, stickers: [String]) {
//        self.layers = layers
//        updateAvatar()
//        updateButtonTitles()
//    }
//
//    func sfCameraViewControllerDidCancel(_ controller: SFCameraViewController) { }
//
//}

extension GenerateAvatarViewController: SFCameraDelegate {
    func camera(_ camera: SFCamera, faceDidDetect frame: CGRect) {
        if faceDetected || locked {
            return
        }
        faceDetected = true
        smallFace = false
        
        DispatchQueue.main.async {
            self.faceDetectTimer?.invalidate()
            self.faceDetectTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.hasFaceDidChange), userInfo: nil, repeats: false)
        }
    }
    
    func cameraFacesDidNotDetect(_ camera: SFCamera) {
        if !faceDetected && !smallFace || locked {
            return
        }
        faceDetected = false
        smallFace = false
        
        DispatchQueue.main.async {
            self.faceDetectTimer?.invalidate()
            self.faceDetectTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.hasFaceDidChange), userInfo: nil, repeats: false)
        }
    }
    
    func cameraFacesSmallDetect(_ camera: SFCamera) {
        if smallFace || locked {
            return
        }
        faceDetected = false
        smallFace = true
        
        DispatchQueue.main.async {
            self.faceDetectTimer?.invalidate()
            self.faceDetectTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.hasFaceDidChange), userInfo: nil, repeats: false)
        }
    }
    
    func camera(_ camera: SFCamera, photoDidTake image: Data) {
        //        effectsController.loader(true) {
        upload(image)
        //        }
        
        //        cameraPlaceholderView.transform = CGAffineTransform(scaleX: 0, y: 0)
        camera.previewLayer?.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        mainView.camera.session.stopRunning()
    }
}
