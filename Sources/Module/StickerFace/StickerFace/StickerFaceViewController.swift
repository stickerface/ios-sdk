import UIKit
import WebKit
import SkeletonView

class StickerFaceViewController: ViewController<StickerFaceView> {
    
    enum PageType {
        case editor
        case main
    }
    
    // MARK: Properties
    
    weak var editorDelegate: StikerFaceEditorDelegate?
    
    private var layers: String
    private var requestId = 0
    
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
        
        mainView.editorViewController.layers = layers
        mainView.mainViewController.updateLayers(layers)
        
        mainView.mainViewController.delegate = self
        mainView.editorViewController.delegate = self
        editorDelegate = mainView.editorViewController
        
        addChildViewController(mainView.editorViewController)
        mainView.editorViewController.didMove(toParentViewController: self)
        
        addChildViewController(mainView.mainViewController)
        mainView.mainViewController.didMove(toParentViewController: self)
        
        updateChild()
        updateBalanceView()
        
        mainView.renderWebView.navigationDelegate = self
        
        do {
            let handler = AvatarRenderResponseHandler()
            handler.delegate = self
            
            mainView.renderWebView.configuration.userContentController.add(handler, name: handler.name)
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainView.backgroundImageView.showSkeleton()
    }
    
    // MARK: Private Actions
    
    @objc private func avatarButtonTapped(_ sender: AvatarButton) {
        // TODO: Что должно происходить при смене пола?
        switch sender.imageType {
        case .settings:
            let viewController = ModalSettingsController()
            viewController.view.layoutIfNeeded()
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
            viewController.view.layoutIfNeeded()
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
        }
    }
    
    @objc private func balanceViewTapped() {
        let ton = UserSettings.tonBalance
        
        UserSettings.tonBalance = ton == nil ? 7.5 : nil
        updateBalanceView()
    }
    
    // MARK: Private methods
    
    private func updateBalanceView() {
        let tonBalance = UserSettings.tonBalance
        
        if let tonBalance = tonBalance {
            mainView.tonBalanceView.balanceType = .connected(ton: tonBalance)
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
        mainView.editorViewController.shouldHideSaveButton(type != .editor)
    }
    
    private func renderAvatar() {
        let tuple = editorDelegate?.layersWithoutBackground(layers)
        let id = getNextRequestId()
        let renderFunc = createRenderFunc(requestId: id, layers: tuple?.layers ?? "", size: Int(AvatarView.Layout.avatarImageViewHeight) * 4)
        
        mainView.renderWebView.evaluateJavaScript(renderFunc)
        
        ImageLoader.setImage(layers: tuple?.background ?? "", imgView: mainView.backgroundImageView, size: mainView.bounds.width) { result in
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
    
}

// MARK: - StikerFaceMainViewControllerDelegate
extension StickerFaceViewController: StikerFaceMainViewControllerDelegate {
    func stikerFaceMainViewController(didSelect sticker: UIImage?) {
        let viewController = ModalShareController(shareImage: sticker)
        viewController.view.layoutIfNeeded()
        
        present(viewController, animated: true)
    }
}

// MARK: - StickerFaceEditorViewControllerDelegate
extension StickerFaceViewController: StickerFaceEditorViewControllerDelegate {
    func stickerFaceEditorViewControllerShouldContinue(_ controller: StickerFaceEditorViewController) {
        type = .main
        mainView.editButton.isHidden = false
        mainView.rightTopButton.setImageType(.settings)
    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didUpdate layers: String) {
        self.layers = layers
        mainView.mainViewController.updateLayers(layers)
        renderAvatar()
    }
    
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSelectPaid layers: String) {
        let modal = ModalBuyController(type: .nft)
        modal.buyView.layoutIfNeeded()
        
        ImageLoader.setAvatar(with: layers,
                              for: modal.buyView.imageView,
                              side: mainView.bounds.width,
                              cornerRadius: 197/2)
        
        present(modal, animated: true)
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
