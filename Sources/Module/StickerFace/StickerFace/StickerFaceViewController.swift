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
        
        mainView.editorViewController.currentLayers = avatar.layers
        mainView.editorViewController.layers = avatar.layers
        
        decodingQueue.async {
            guard
                let personData = avatar.personImage,
                let backgroundData = avatar.backgroundImage
            else { return }
            
            let personImage = UIImage(data: personData)
            let backgroundImage = UIImage(data: backgroundData)
            
            DispatchQueue.main.async {
                self.mainView.avatarView.avatarImageView.image = personImage
                self.mainView.backgroundImageView.image = backgroundImage
            }
        }
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
             
        setupEditor()
        setupActions()
        setupButtons()
        updateBalanceView()
        
        mainView.renderWebView.navigationDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(tonClientDidUpdate), name: .tonClientDidUpdate, object: nil)
        
        let handler = AvatarRenderResponseHandler()
        handler.delegate = self
        
        mainView.renderWebView.configuration.userContentController.add(handler, name: handler.name)
        mainView.renderWebView.load(URLRequest(url: URL(string: "https://stickerface.io/render.html")!))
    }
    
    // MARK: Private Actions
    
    @objc private func avatarButtonTapped(_ sender: AvatarButton) {
        switch sender.imageType {
        case .settings:
            let viewController = ModalSettingsController()
            
            present(viewController, animated: true)
            
        case .male:
            sender.setImageType(.female)
            editorDelegate?.setGender(.female)
            
        case .female:
            sender.setImageType(.male)
            editorDelegate?.setGender(.male)
            
        case .edit:
            mainView.tonBalanceView.isHidden = true
            mainView.backButton.isHidden = false
            mainView.genderButton.setImageType(.male)
            
        case .hanger:
            let viewController = ModalWardrobeController()
            viewController.delegate = self
            
            present(viewController, animated: true)
            
        case .close:
            mainView.genderButton.setImageType(.settings)
            
        case .back:
            if layers == mainView.editorViewController.layers {
                cancelChanges()
                break
            }
            layers = mainView.editorViewController.layers
            mainView.editorViewController.currentLayers = layers
//            renderAvatar()
//            needToRedieve = true
            cancelChanges()
            
        case .logout:
            let alert = UIAlertController(title: "Are sure you want to log out?", message: "After logging out you will not be able to buy NFTs for your avatar", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let logoutAction = UIAlertAction(title: "Log out", style: .default) { _ in
                StickerFace.shared.logoutUser()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(logoutAction)
            
            present(alert, animated: true)
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
        mainView.hangerButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        mainView.backButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
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
        mainView.hangerButton.setCount(SFDefaults.wardrobe.count)
        mainView.tonBalanceView.isHidden = true
        mainView.backButton.isHidden = !SFDefaults.wasEdited
    }
            
    private func renderAvatar() {
        let tuple = editorDelegate?.layersWithout(section: "background", layers: layers)
        let id = getNextRequestId()
        let renderFunc = createRenderFunc(requestId: id, layers: tuple?.layers ?? "", size: Int(AvatarView.Layout.avatarImageViewHeight) * 4)
        
        mainView.renderWebView.evaluateJavaScript(renderFunc)
        
        // Render with webView
        if let layer = tuple?.sectionLayer, layer != "0" {
            StickerLoader.loadSticker(into: mainView.backgroundImageView, with: layer, stickerType: .section) { result in
                switch result {
                case .success: self.mainView.backgroundImageView.hideSkeleton()
                case .failure: break
                }
            }
        }
    }
    
    private func createRenderFunc(requestId: Int, layers: String, size: Int) -> String {
        return "renderPNG(\"\(layers)\", \(requestId), \(size))"
    }
    
    private func getNextRequestId() -> Int {
        let current = requestId
        requestId = (current + 1) % Int.max
        
        return current
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
        
        if layers != avatar.layers || avatar.avatarImage == nil {
            StickerLoader.shared.loadImage(url: StickerLoader.avatarPath + layers) { [weak self] image in
                guard let self = self else { return }
                
                let avatarImage = image.pngData() ?? Data()
                let personImage = (self.mainView.avatarView.avatarImageView.image ?? UIImage()).pngData()
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
        let alert = UIAlertController(title: "Are you sure you want to leave?", message: "The changes you made won't be saved.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let logoutAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            StickerFace.shared.cancelChange()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        present(alert, animated: true)
    }
}

// MARK: - StickerFaceEditorViewControllerDelegate
extension StickerFaceViewController: StickerFaceEditorViewControllerDelegate {
    func stickerFaceEditorViewControllerDidLoadLayers(_ controller: StickerFaceEditorViewController) {

    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didUpdate layers: String) {
        self.layers = layers
        renderAvatar()
    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSave layers: String) {
        SFDefaults.gender = mainView.genderButton.imageType == .female ? .female : .male
        self.layers = layers
        receiveAvatar()
    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSelectPaid layer: String, layers withLayer: String, with price: Int, layerType: LayerType) {
        let modal = ModalNewLayerController(type: layerType)
        let balance = SFDefaults.tonBalance
        modal.updateView(layer: layer, layers: withLayer, balance: balance, price: price)
        modal.delegate = self
        
        present(modal, animated: true)
    }
}

// MARK: - ModalNewLayerDelegate
extension StickerFaceViewController: ModalNewLayerDelegate {
    func modalNewLayerController(_ controller: ModalNewLayerController, didBuy layer: String, layerType: LayerType, allLayers: String) {
        if layerType == .NFT {
            var wardrobe = SFDefaults.wardrobe
            wardrobe.append(layer)
            mainView.hangerButton.setCount(wardrobe.count)
            SFDefaults.wardrobe = wardrobe
        }
        
        if layerType == .background {
            var backgounds = SFDefaults.paidBackgrounds
            backgounds.append(layer)
            SFDefaults.paidBackgrounds = backgounds
        }
        
        updateCurrentLayers(allLayers)
        
        controller.dismiss(animated: true)
    }
    
    func modalNewLayerController(_ controller: ModalNewLayerController, didSave layer: String, allLayers: String) { }
}

// MARK: - ModalWardrobeDelegate
extension StickerFaceViewController: ModalWardrobeDelegate {
    func modalWardrobeController(_ controller: ModalWardrobeController, didSave layers: String) {
        updateCurrentLayers(layers)
    }
    
    func modalWardrobeController(_ controller: ModalWardrobeController, needLayers forLayer: String) -> String {
        return editorDelegate?.replaceCurrentLayers(with: forLayer, with: nil, isCurrent: true) ?? ""
    }
}

// MARK: - AvatarRenderResponseHandlerDelegate
extension StickerFaceViewController: AvatarRenderResponseHandlerDelegate {
    func onImageReady(base64: String) {
        decodingQueue.async {
            guard
                let data = Data(base64Encoded: base64, options: []),
                let image = UIImage(data: data)
            else { return  }
            
            DispatchQueue.main.async {
                self.mainView.avatarView.avatarImageView.image = image
                
                if self.needToRedieve {
                    self.receiveAvatar()
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension StickerFaceViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        renderAvatar()
    }
}
