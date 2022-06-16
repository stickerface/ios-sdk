import UIKit
import WebKit
import SkeletonView

class StickerFaceViewController: ViewController<StickerFaceView> {
        
    // MARK: Properties
    
    weak var editorDelegate: StickerFaceEditorDelegate?
    
    private var needToRedieve: Bool = false
    private var requestId = 0
    private var layers: String {
        didSet {
            SFDefaults.layers = layers
        }
    }
        
    // MARK: Initalization
    
    init(avatar: SFAvatar) {
        self.layers = avatar.layers
        super.init(nibName: nil, bundle: nil)
        
        mainView.avatarView.avatarImageView.image = UIImage(data: avatar.personImage ?? Data())
        mainView.backgroundImageView.image = UIImage(data: avatar.backgroundImage ?? Data())
        
        if let url = URL(string: "https://stickerface.io/render.html") {
            mainView.renderWebView.load(URLRequest(url: url))
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
        updateChild()
        updateBalanceView()
        
        mainView.renderWebView.navigationDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(tonClientDidUpdate), name: .tonClientDidUpdate, object: nil)
        
        do {
            let handler = AvatarRenderResponseHandler()
            handler.delegate = self
            
            mainView.renderWebView.configuration.userContentController.add(handler, name: handler.name)
        }
    }
    
    // MARK: Private Actions
    
    @objc private func avatarButtonTapped(_ sender: AvatarButton) {
        switch sender.imageType {
        case .settings:
            let viewController = ModalSettingsController()
            
            present(viewController, animated: true)
            
        case .male:
            sender.setImageType(.female)
            editorDelegate?.toggleGender()
            
        case .female:
            sender.setImageType(.male)
            editorDelegate?.toggleGender()
            
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
            layers = mainView.editorViewController.layers
            mainView.editorViewController.currentLayers = layers
            mainView.editorViewController.updateSelectedLayers()
            renderAvatar()
            needToRedieve = true
            
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
        mainView.editorViewController.currentLayers = layers
        mainView.editorViewController.layers = layers
        
        mainView.editorViewController.delegate = self
        editorDelegate = mainView.editorViewController
        
        addChildViewController(mainView.editorViewController)
        mainView.editorViewController.didMove(toParentViewController: self)
    }
    
    private func updateBalanceView() {
        if let tonClient = SFDefaults.tonClient {
            mainView.tonBalanceView.balanceType = .connected(ton: tonClient.balance)
        } else {
            mainView.tonBalanceView.balanceType = .disconnected
        }
    }
    
    private func updateChild() {
        mainView.editorViewController.view.alpha = 1
        mainView.mainViewController.view.alpha = 0
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
        let layersWitoutBack = editorDelegate?.layersWithout(section: "background", layers: layers).layers ?? ""
        
        self.layers = layers
        mainView.mainViewController.updateLayers(layersWitoutBack)
        editorDelegate?.updateLayers(layers)
        renderAvatar()
    }
    
    private func receiveAvatar() {
        let path = StickerLoader.avatarPath + layers
        StickerLoader.shared.loadImage(url: path) { [weak self] image in
            guard let self = self else { return }
            
            let avatarImage = UIImagePNGRepresentation(image) ?? Data()
            let personImage = UIImagePNGRepresentation(self.mainView.avatarView.avatarImageView.image ?? UIImage())
            let backgroundImage = UIImagePNGRepresentation(self.mainView.backgroundImageView.image ?? UIImage())
            let avatar = SFAvatar(avatarImage: avatarImage, personImage: personImage, backgroundImage: backgroundImage, layers: self.layers)
            
            StickerFace.shared.receiveAvatar(avatar)
        }
    }
}

// MARK: - StickerFaceMainViewControllerDelegate
extension StickerFaceViewController: StickerFaceMainViewControllerDelegate {
    func stickerFaceMainViewController(needAllLayers withLayers: [(layer: String, color: String?)], needBack: Bool) -> String {
        var allLayers = mainView.editorViewController.currentLayers
        let tmpLayers = mainView.editorViewController.currentLayers
        
        // TODO: - может метод сделать где параметр будет все лееры и не парется с создаванием промежуточных лееров?
        for layer in withLayers {
            allLayers = editorDelegate?.replaceCurrentLayers(with: layer.layer, with: layer.color, isCurrent: false) ?? ""
            mainView.editorViewController.currentLayers = allLayers
        }
        
        mainView.editorViewController.currentLayers = tmpLayers
        
        if needBack {
            return allLayers
        } else {
            return editorDelegate?.layersWithout(section: "background", layers: allLayers).layers ?? ""
        }
    }
    
    func stickerFaceMainViewController(didSelect sticker: UIImage?) {
        let viewController = ModalShareController(shareImage: sticker)
        viewController.view.layoutIfNeeded()
        
        present(viewController, animated: true)
    }
}

// MARK: - StickerFaceEditorViewControllerDelegate
extension StickerFaceViewController: StickerFaceEditorViewControllerDelegate {
    func stickerFaceEditorViewControllerDidLoadLayers(_ controller: StickerFaceEditorViewController) {
        let layersWitoutBack = editorDelegate?.layersWithout(section: "background", layers: layers).layers ?? ""
        mainView.mainViewController.updateLayers(layersWitoutBack)
    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didUpdate layers: String) {
        self.layers = layers
        renderAvatar()
    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSave layers: String) {
        self.layers = layers
                
//        let layersWitoutBack = editorDelegate?.layersWithout(section: "background", layers: layers).layers ?? ""
//        mainView.mainViewController.updateLayers(layersWitoutBack)
//        mainView.tonBalanceView.isHidden = false
//        mainView.backButton.isHidden = true
//        mainView.editButton.isHidden = false
//        mainView.editButton.isHidden = false
//        mainView.rightTopButton.setImageType(.settings)
//        type = .main
        
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
    func modalNewLayerController(_ controller: ModalNewLayerController, didSave layer: String, allLayers: String) {
        
    }
    
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
        if let data = Data(base64Encoded: base64, options: []) {
            mainView.avatarView.avatarImageView.image = UIImage(data: data)
            if needToRedieve {
                receiveAvatar()
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
