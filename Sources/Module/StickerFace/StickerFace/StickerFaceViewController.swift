import UIKit
import WebKit
import SkeletonView

class StickerFaceViewController: ViewController<StickerFaceView> {
        
    // MARK: Properties
    
    weak var editorDelegate: StickerFaceEditorDelegate?
    
    let decodingQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).decodingQueue")
    
    private var needToRedieve: Bool = false
    private var requestId = 0
    private var avatar: SFAvatar
    private var layers: String 
        
    // MARK: Initalization
    
    init(avatar: SFAvatar) {
        self.avatar = avatar
        self.layers = avatar.layers
        super.init(nibName: nil, bundle: nil)
        
        recognizeGender()
        
        mainView.editorViewController.layers = avatar.layers
        mainView.editorViewController.currentLayers = avatar.layers
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.avatarView.avatar = avatar
        mainView.backgroundImageView.image = UIImage(data: avatar.backgroundImage ?? .init())
        
        setupEditor()
        setupActions()
        setupButtons()
        updateBalanceView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tonClientDidUpdate), name: .tonClientDidUpdate, object: nil)
    }
    
    // MARK: Private Actions
    
    @objc private func avatarButtonTapped(_ sender: AvatarButton) {
        switch sender.imageType {
        case .male:
            sender.setImageType(.female)
            editorDelegate?.setGender(.female)
            
        case .female:
            sender.setImageType(.male)
            editorDelegate?.setGender(.male)
                    
        case .back:
            cancelChanges()
            
        case .genetateAvatar:
            let vc = GenerateAvatarViewController(type: .justGenerate(delegate: self))
            vc.mainView.backButton.isHidden = false
            
            navigationController?.pushViewController(vc, animated: true)
          
        default:
            break
        }
    }
    
    @objc private func balanceViewTapped() {
        if mainView.tonBalanceView.balanceType == .disconnected {
            TonNetwork.authRequest()
        }
    }
    
    @objc private func tonClientDidUpdate() {
        updateBalanceView()
    }
    
    // MARK: Private methods
    
    private func setupActions() {
        let balanceGesture = UITapGestureRecognizer(target: self, action: #selector(balanceViewTapped))
        mainView.tonBalanceView.addGestureRecognizer(balanceGesture)
        
        mainView.genderButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        mainView.backButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        mainView.genetateAvatarButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
    }
    
    private func setupEditor() {
        mainView.editorViewController.delegate = self
        editorDelegate = mainView.editorViewController
        
        addChild(mainView.editorViewController)
        mainView.editorViewController.didMove(toParent: self)
    }
    
    private func updateBalanceView() {
        if let tonClient = SFDefaults.tonClient {
            mainView.tonBalanceView.balanceType = .connected(ton: tonClient.balance)
        } else {
            mainView.tonBalanceView.balanceType = .disconnected
        }
    }
    
    private func setupButtons() {
        let genderType: AvatarButton.ImageType = SFDefaults.gender == .male ? .male : .female
        
        mainView.backButton.isHidden = true
        mainView.genderButton.setImageType(genderType)
        mainView.tonBalanceView.isHidden = true
        mainView.backButton.isHidden = !SFDefaults.wasEdited
    }
            
    private func renderAvatar() {
        guard let editorDelegate = editorDelegate else { return }
        let tuple = editorDelegate.layersWithout(section: "background", layers: layers)
        let avatar = SFAvatar(avatarImage: nil,
                              personImage: nil,
                              backgroundImage: nil,
                              layers: layers,
                              personLayers: tuple.layers,
                              backgroundLayer: tuple.sectionLayer)
        mainView.avatarView.avatar = avatar
    }
    
    private func renderBackground() {
        guard let editorDelegate = editorDelegate else { return }
        let tuple = editorDelegate.layersWithout(section: "background", layers: layers)
        let size = mainView.backgroundImageView.frame.size.maxSide
        
        if tuple.sectionLayer != "0" {
            StickerLoader.shared.renderLayer(tuple.sectionLayer, size: size) { [weak self] image in
                guard let self = self else { return }
                self.mainView.backgroundImageView.image = image
            }
        }
    }
    
    private func updateCurrentLayers(_ layers: String) {
        self.layers = layers
        editorDelegate?.updateLayers(layers)
        renderAvatar()
    }
    
    private func receiveAvatar() {
        let tupleLayers = editorDelegate?.layersWithout(section: "background", layers: layers)
        let personLayers = tupleLayers?.layers
        let backgroundLayer = tupleLayers?.sectionLayer
        
        if !Utils.compareLayers(layers, avatar.layers) || avatar.avatarImage == nil {
            let size = mainView.avatarView.frame.size.maxSide
            StickerLoader.shared.renderLayer(layers, size: size) { image in
                let avatarImage = image.pngData() ?? Data()
                let personImage = self.mainView.avatarView.avatar?.personImage
                let backgroundImage = (self.mainView.backgroundImageView.image ?? UIImage()).pngData()
                let avatar = SFAvatar(
                    avatarImage: avatarImage,
                    personImage: personImage,
                    backgroundImage: backgroundImage,
                    layers: self.layers,
                    personLayers: personLayers,
                    backgroundLayer: backgroundLayer
                )
                
                StickerFace.shared.receiveAvatar(avatar)
            }
        } else {
            StickerFace.shared.receiveAvatar(avatar)
        }
    }
    
    private func cancelChanges() {
        if Utils.compareLayers(layers, mainView.editorViewController.layers) {
            layers = mainView.editorViewController.layers
            mainView.editorViewController.currentLayers = layers
            
            StickerFace.shared.cancelChange()
        } else {
            let alert = UIAlertController(
                title: "editorLeaveTitle".libraryLocalized,
                message: "editorLeaveMessage".libraryLocalized,
                preferredStyle: .alert
            )
            
            let cancelAction = UIAlertAction(
                title: "editorLeaveCancel".libraryLocalized,
                style: .cancel
            )
            let logoutAction = UIAlertAction(
                title: "editorLeaveAgree".libraryLocalized,
                style: .destructive,
                handler: { _ in StickerFace.shared.cancelChange() }
            )
            
            alert.addAction(cancelAction)
            alert.addAction(logoutAction)
            
            present(alert, animated: true)
        }
    }
    
    private func recognizeGender() {
        let layersArray = layers.components(separatedBy: ";")
        SFDefaults.gender = layersArray.contains("1") ? .male : .female
    }
}

// MARK: - StickerFaceEditorViewControllerDelegate

extension StickerFaceViewController: StickerFaceEditorControllerDelegate {
    func stickerFaceEditor(didLoadLayers controller: StickerFaceEditorViewController) { }
    
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didUpdate layers: String) {
        self.layers = layers
        renderAvatar()
    }
    
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didUpdateBackground layers: String) {
        self.layers = layers
        renderBackground()
    }
    
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didSave layers: String) {
        SFDefaults.gender = mainView.genderButton.imageType == .female ? .female : .male
        self.layers = layers
        receiveAvatar()
    }
    
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didSelectPaid layer: String, layers withLayer: String, with price: Int, layerType: LayerType) {
    }
}

// MARK: - GenerateAvatarDelegate

extension StickerFaceViewController: GenerateAvatarDelegate {
    func generateAvatar(controller: GenerateAvatarViewController, didGenerate avatar: SFAvatar) {
        let layersArray = avatar.layers.components(separatedBy: ";")
        let gender: SFDefaults.Gender = layersArray.contains("1") ? .male : .female
        let buttonGender: AvatarButton.ImageType = layersArray.contains("1") ? .male : .female
        
        mainView.genderButton.setImageType(buttonGender)
        SFDefaults.gender =  gender
        self.layers = avatar.layers
        
        editorDelegate?.updateLayers(avatar.layers)
        editorDelegate?.updateEditor(for: gender)
        
        mainView.avatarView.avatar = avatar
        
        navigationController?.popViewController(animated: true)
    }
}
