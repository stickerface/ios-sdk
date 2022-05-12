import UIKit
import WebKit
import SkeletonView

class StickerFaceViewController: ViewController<StickerFaceView> {
    
    enum PageType {
        case editor
        case main
    }
    
    // MARK: Properties
    
    weak var editorDelegate: StickerFaceEditorDelegate?
    
    private var requestId = 0
    private var layers: String {
        didSet {
            UserSettings.layers = layers
        }
    }
    
    private var type: PageType = .main {
        didSet {
            updateChild()
        }
    }
    
    // MARK: Initalization
    
    init(type: PageType, layers: String) {
        self.type = type
        self.layers = layers
        super.init(nibName: nil, bundle: nil)
        
        setupView(with: type)
        
        if let url = URL(string: "https://stickerface.io/render.html") {
            mainView.renderWebView.load(URLRequest(url: url))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.rightTopButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        mainView.editButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        mainView.hangerButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        mainView.backButton.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        
        let balanceGesture = UITapGestureRecognizer(target: self, action: #selector(balanceViewTapped))
        mainView.tonBalanceView.addGestureRecognizer(balanceGesture)
        
        mainView.editorViewController.currentLayers = layers
        mainView.editorViewController.layers = layers
        
        mainView.mainViewController.delegate = self
        mainView.editorViewController.delegate = self
        editorDelegate = mainView.editorViewController
        
        addChildViewController(mainView.editorViewController)
        mainView.editorViewController.didMove(toParentViewController: self)
        
        addChildViewController(mainView.mainViewController)
        mainView.mainViewController.didMove(toParentViewController: self)
        
        updateChild()
        updateBalanceView()
        
        mainView.hangerButton.setCount(UserSettings.wardrobe.count)
        mainView.renderWebView.navigationDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(tonClientDidUpdate), name: .tonClientDidUpdate, object: nil)
        
        do {
            let handler = AvatarRenderResponseHandler()
            handler.delegate = self
            
            mainView.renderWebView.configuration.userContentController.add(handler, name: handler.name)
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainView.backgroundImageView.showSkeleton(usingColor: .clouds)
    }
    
    // MARK: Private Actions
    
    @objc private func avatarButtonTapped(_ sender: AvatarButton) {
        // TODO: Что должно происходить при смене пола?
        switch sender.imageType {
        case .settings:
            let viewController = ModalSettingsController()
            
            present(viewController, animated: true)
            
        case .male:
            UserSettings.gender = .female
            sender.setImageType(.female)
            
        case .female:
            UserSettings.gender = .male
            sender.setImageType(.male)
            
        case .edit:
            mainView.tonBalanceView.isHidden = true
            mainView.backButton.isHidden = false
            mainView.editButton.isHidden = true
            mainView.rightTopButton.setImageType(.male)
            type = .editor
            
        case .hanger:
            let viewController = ModalWardrobeController()
            viewController.delegate = self
            
            present(viewController, animated: true)
            
        case .close:
            mainView.editButton.isHidden = false
            mainView.rightTopButton.setImageType(.settings)
            type = .main
            
        case .back:
            mainView.tonBalanceView.isHidden = false
            mainView.backButton.isHidden = true
            mainView.editButton.isHidden = false
            mainView.rightTopButton.setImageType(.settings)
            type = .main
            
            self.layers = mainView.editorViewController.layers
            mainView.editorViewController.currentLayers = layers
            mainView.editorViewController.updateSelectedLayers()
            renderAvatar()
        }
    }
    
    @objc private func balanceViewTapped() {
        if mainView.tonBalanceView.balanceType == .disconnected {
            let path = "https://app.tonkeeper.com/ton-login/stickerface.io/api/tonkeeper/authRequest"
            let url = URL(string: path)
            
            if let url = url {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @objc private func tonClientDidUpdate() {
        updateBalanceView()
    }
    
    // MARK: Private methods
    
    private func updateBalanceView() {
        if let tonClient = UserSettings.tonClient {
            mainView.tonBalanceView.balanceType = .connected(ton: tonClient.balance)
        } else {
            mainView.tonBalanceView.balanceType = .disconnected
        }
    }
    
    private func updateChild() {
        mainView.editorViewController.view.alpha = type == .editor ? 1 : 0
        mainView.mainViewController.view.alpha = type == .main ? 1 : 0
    }
    
    private func setupView(with type: PageType) {
        let genderType: AvatarButton.ImageType = UserSettings.gender == .male ? .male : .female
        
        mainView.backButton.isHidden = true
        mainView.editButton.isHidden = type == .editor
        mainView.rightTopButton.setImageType(type == .editor ? genderType : .settings)
    }
    
    private func renderAvatar() {
        let tuple = editorDelegate?.layersWithout(section: "background", layers: layers)
        let id = getNextRequestId()
        let renderFunc = createRenderFunc(requestId: id, layers: tuple?.layers ?? "", size: Int(AvatarView.Layout.avatarImageViewHeight) * 4)
        
        mainView.renderWebView.evaluateJavaScript(renderFunc)
        
        let layer = tuple?.sectionLayer ?? ""
        let url = "https://stickerface.io/api/section/png/\(layer)?size=\(mainView.bounds.width)"
        
        ImageLoader.setImage(url: url, imgView: mainView.backgroundImageView) { result in
            switch result {
            case .success: self.mainView.backgroundImageView.hideSkeleton()
            case .failure: break
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
}

// MARK: - StickerFaceMainViewControllerDelegate
extension StickerFaceViewController: StickerFaceMainViewControllerDelegate {
    func stickerFaceMainViewController(needAllLayers withLayers: [(layer: String, color: String?)]) -> String {
        var allLayers = ""
        let tmpLayers = mainView.editorViewController.currentLayers
        
        // TODO: - может метод сделать где параметр будет все лееры и не парется с создаванием промежуточных лееров?
        for layer in withLayers {
            allLayers = editorDelegate?.replaceCurrentLayers(with: layer.layer, with: layer.color) ?? ""
            mainView.editorViewController.currentLayers = allLayers
        }
        
        mainView.editorViewController.currentLayers = tmpLayers
        
        return editorDelegate?.layersWithout(section: "background", layers: allLayers).layers ?? ""
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
        let layersWitoutBack = editorDelegate?.layersWithout(section: "background", layers: layers).layers ?? ""
        mainView.mainViewController.updateLayers(layersWitoutBack)
        mainView.tonBalanceView.isHidden = false
        mainView.backButton.isHidden = true
        mainView.editButton.isHidden = false
        mainView.editButton.isHidden = false
        mainView.rightTopButton.setImageType(.settings)
        type = .main
    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSelectPaid layer: String, layers withLayer: String, with price: Int, layerType: LayerType) {
        let modal = ModalNewLayerController(type: layerType)
        let balance = UserSettings.tonBalance
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
            var wardrobe = UserSettings.wardrobe
            wardrobe.append(layer)
            mainView.hangerButton.setCount(wardrobe.count)
            UserSettings.wardrobe = wardrobe
        }
        
        if layerType == .background {
            var backgounds = UserSettings.paidBackgrounds
            backgounds.append(layer)
            UserSettings.paidBackgrounds = backgounds
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
        return editorDelegate?.replaceCurrentLayers(with: forLayer, with: nil) ?? ""
    }
}

// MARK: - AvatarRenderResponseHandlerDelegate
extension StickerFaceViewController: AvatarRenderResponseHandlerDelegate {
    
    func onImageReady(base64: String) {
        if let data = Data(base64Encoded: base64, options: []) {
            mainView.avatarView.avatarImageView.image = UIImage(data: data)
            mainView.avatarView.hideSkeleton()
        }
    }
    
}

// MARK: - WKScriptMessageHandler
extension StickerFaceViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        renderAvatar()
    }
    
}
