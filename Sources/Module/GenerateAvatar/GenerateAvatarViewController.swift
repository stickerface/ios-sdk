import UIKit
import AVFoundation

class GenerateAvatarViewController: ViewController<GenerateAvatarView> {
    
    enum InfoLabels {
        case waitingCameraAccess
        case noFace
        case smallFace
        case takingPhoto
        case nothing
    }
    
    private var layers: String?
    private var shouldAutoOpenCamera: Bool = true
    private var isAvatarGenerated: Bool = false
    private var isCameraStarting: Bool = false
    private var faceDetected: Bool = false
    private var smallFace: Bool = false
    private var locked: Bool = false
    private var faceDetectTimer: Timer?
    private let decodingQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).decodingQueue")
    private let provider = GenerateAvatarProvider()
    
    private let player: AVPlayer = {
        let path = Bundle.resourceBundle.path(forResource: "onboardingAvatar", ofType: "mp4")!
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        
        return player
    }()
    
    var infoLabel: InfoLabels = .waitingCameraAccess {
        didSet {
            DispatchQueue.main.async {
                self.updateInfoLabel()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.linesRoundRotateAnimationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCamera)))
        mainView.mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        mainView.secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        
        mainView.camera.delegate = self
        
        mainView.onboardingAvatarVideoView.playerLayer.player = player
        
        provider.delegate = self
        
        play()
        bindEvents()
        updateButtonTitles()
        StickerLoader.loadSticker(into: mainView.avatarImageView, placeholderImage: UIImage(libraryNamed: "defaultAvatar"))
        mainView.avatarImageView.alpha = 0
    }
    
    // MARK: - Private Actions
    
    @objc private func bindEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(play), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc private func close() {
        mainView.linesRoundRotateAnimationView.rotate()
        
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
        initCamera()
    }
    
    @objc private func secondaryButtonTapped() {
        if isAvatarGenerated {
            isAvatarGenerated = false
            updateButtonTitles()
            initCamera()
        } else {
            shouldAutoOpenCamera = false
            layers = StickerLoader.defaultLayers
            mainView.avatarImageView.alpha = 0
            close()
            isAvatarGenerated = true
            defaultLayersTapped()
        }
    }
    
    @objc private func mainButtonTapped() {
        if isAvatarGenerated {
            nextStep()
        } else {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            if status == .authorized {
                if isCameraStarting {
                    faceDetectTimer = nil
                    mainView.linesRoundRotateAnimationView.setState(true)
                    takePhoto()
                } else {
                    close()
                }
            } else {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
            }
        }
    }
    
    @objc private func hasFaceDidChange() {
        if faceDetected {
            mainView.linesRoundRotateAnimationView.setState(true)
            faceDetectTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(takePhoto), userInfo: nil, repeats: false)
        } else if smallFace {
            infoLabel = .smallFace
        } else {
            infoLabel = .noFace
        }
        
        mainView.linesRoundRotateAnimationView.setState(faceDetected)
    }
    
    @objc private func takePhoto() {
        locked = true
        mainView.camera.capturePhoto()
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
                        self?.openCamera()
                    }
                }
            }
        } else if status == .authorized {
            openCamera()
        }
        
        updateButtonTitles()
    }
    
    private func updateAvatar() {
        mainView.camera.previewLayer.alpha = 0
        mainView.avatarPlaceholderView.alpha = 0
        mainView.linesRoundRotateAnimationView.alpha = 0
        mainView.descriptionLabel.alpha = 0
        mainView.avatarImageView.alpha = 1
        mainView.backgroundImageView.alpha = 1
        isAvatarGenerated = true
        
        StickerLoader.loadSticker(into: mainView.avatarImageView, with: layers ?? "") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.layers = StickerLoader.defaultLayers
                self.mainView.avatarImageView.image = UIImage(libraryNamed: "defaultAvatar")
                
            default: break
            }
        }
    }
    
    private func defaultLayersTapped() {
        let avatarBase: String = .avatarBase64()
        let personBase: String = .personBase64()
        let backgroundBase: String = .backgraoundBase64()
        
        decodingQueue.async {
            guard
                let avatarData = Data(base64Encoded: avatarBase),
                let personData = Data(base64Encoded: personBase),
                let backgroundData = Data(base64Encoded: backgroundBase)
            else { return  }
            
            let sfAvatar = SFAvatar(
                avatarImage: avatarData,
                personImage: personData,
                backgroundImage: backgroundData,
                layers: "428;" + StickerLoader.defaultLayers,
                personLayers: StickerLoader.defaultLayers,
                backgroundLayer: "428"
            )
            
            DispatchQueue.main.async {
                let vc = StickerFaceViewController(avatar: sfAvatar)
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        }
    }
    
    private func nextStep() {
        guard let layers = layers else { return }
        
        let background = (mainView.backgroundImageView.image ?? UIImage()).pngData()
        let person = (mainView.avatarImageView.image ?? UIImage()).pngData()
        
        StickerLoader.shared.renderLayer("428;\(layers)") { [weak self] image in
            guard let self = self else { return }
            
            let sfAvatar = SFAvatar(
                avatarImage: image.pngData(),
                personImage: person,
                backgroundImage: background,
                layers: "428;" + layers,
                personLayers: layers,
                backgroundLayer: "428"
            )
            
            let vc = StickerFaceViewController(avatar: sfAvatar)
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    private func updateButtonTitles() {
        let secondaryTitle: String
        let mainTitle: String
        
        if isAvatarGenerated {
            secondaryTitle = "setupAvatarGenerateNewTitle".libraryLocalized
            mainTitle = "commonContinue".libraryLocalized
        } else {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            mainTitle = status == .authorized ?
            "setupAvatarGenerateTitle".libraryLocalized :
            "setupAvatarAllowTitle".libraryLocalized
            
            secondaryTitle = "setupAvatarContinueTitle".libraryLocalized
        }
        
        mainView.mainButton.setTitle(mainTitle, for: .normal)
        mainView.secondaryButton.setTitle(secondaryTitle, for: .normal)
    }
    
    private func initCamera() {
        mainView.avatarPlaceholderView.alpha = 1
        mainView.linesRoundRotateAnimationView.alpha = 1
        mainView.avatarImageView.alpha = 0
        mainView.backgroundImageView.alpha = 0
        mainView.camera.previewLayer.alpha = 1
        
        mainView.linesRoundRotateAnimationView.setState(false)
        mainView.linesRoundRotateAnimationView.loader(false, completion: { [weak self] in
            guard let self = self else { return }
            let session = self.mainView.camera.session
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
                self.isCameraStarting = true
            }
        })
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
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
    
    private func upload(_ image: Data) {
        let resizedImage = resizeImage(image: UIImage(data: image, scale: 1.0)!, targetSize: CGSize(width: 600, height: 600))
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.9) else { return }
        provider.uploadImage(imageData: imageData)
    }
    
    private func setupLayers(_ layers: String) {
        DispatchQueue.main.async {
            self.layers = layers
            self.locked = false
            self.smallFace = false
            self.faceDetected = false
            
            self.updateAvatar()
            self.updateButtonTitles()
        }
    }
    
    private func updateInfoLabel() {
        var text: String
        switch infoLabel {
        case .waitingCameraAccess:
            text = "setupAvatarWaitingCameraAccess".libraryLocalized
        case .noFace:
            text = "setupAvatarNoFace".libraryLocalized
        case .smallFace:
            text = "setupAvatarSmallFace".libraryLocalized
        case .takingPhoto:
            text = "setupAvaterTakingPhoto".libraryLocalized
        case .nothing:
            text = ""
        }
        
        mainView.subtitleLabel.text = text
    }
}

// MARK: - SFCameraDelegate
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
        mainView.avatarPlaceholderView.alpha = 0
        camera.previewLayer.alpha = 0
        
        mainView.linesRoundRotateAnimationView.loader(true) {
            self.upload(image)
        }
        
        mainView.camera.session.stopRunning()
    }
}

// MARK: - GenerateAvatarProviderDelegate
extension GenerateAvatarViewController: GenerateAvatarProviderDelegate {
    func generateAvatarProvider(didSuccessWith response: GenerateAvatarResponse) {
        setupLayers(response.model)
    }
    
    func generateAvatarProvider(didFailWith error: Error) {
        setupLayers(StickerLoader.defaultLayers)
    }
}
