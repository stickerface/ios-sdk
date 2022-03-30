import UIKit
import StickerFaceEditor
import AVFoundation

class GenerateAvatarViewController: ViewController<GenerateAvatarView> {
    
    private var layers: String?
    private var shouldAutoOpenCamera: Bool = true
    private var cameraOpenCount: Int = 0
    private var isAvatarGenerated: Bool = false
    
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
        
        StickerFace.shared.tintColor = .sfAccentBrand
        let controller = StickerFace.shared.getCameraViewController()
        controller.copyrightVisible = false
        controller.delegate = self
        
        present(controller, animated: true)
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
        
        let vc = StickerFaceViewController(layers: layers)
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
}

// MARK: - SFCameraViewControllerDelegate

extension GenerateAvatarViewController: SFCameraViewControllerDelegate {
    
    func sfCameraViewController(_ controller: SFCameraViewController, didGenerate layers: String, stickers: [String]) {
        self.layers = layers
        updateAvatar()
        updateButtonTitles()
    }
    
    func sfCameraViewControllerDidCancel(_ controller: SFCameraViewController) { }
    
}
