import UIKit
import SnapKit

class HolderView: UIView {
    
    var view = UIView()
    
    init(view: UIView) {
        self.view = view
        super.init(frame: .zero)
        
        addSubview(self.view)
        
        self.view.snp.makeConstraints { make in
            let height = FCKeyboardManager.shared.keyBoardHeight
            if height.isZero {
                make.center.equalToSuperview()
            } else {
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(12)
            }
            
            make.left.right.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        view.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview()
        }
        
        layoutIfNeeded()
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        view.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        layoutIfNeeded()
    }
    
}

class PlaceholderView: UIView {
    
    var shouldFade: Bool = false {
        didSet {
            alpha = shouldFade ? 0.0 : 1.0
        }
    }
    
    var small = false {
        didSet {
            let size = small ? 160.0 : AvatarView.Layout.avatarImageViewHeight
            avatarView.snp.updateConstraints { update in
                update.size.equalTo(size)
            }
        }
    }
    
    var caption: String = "" {
        didSet {
            captionView.text = caption
        }
    }
    
    var buttonText: String = "" {
        didSet {
            actionButton.setTitle(buttonText, for: .normal)
            actionButton.isHidden = buttonText.count == 0
            
            let textWidth = buttonText.size(withAttributes: [.font: SFPalette.font]).width
            actionButton.snp.updateConstraints { update in
                update.width.equalTo(textWidth + 16.0 * 2)
            }
        }
    }

    var stickerId: Stickers = .ok {
        didSet {
            updateAvatarView()
        }
    }
    
    enum Stickers: Int {
        case none = 0
        case nervous = 2
        case ok = 4
        case veryCrying = 16
        case hi = 20
        case sticker21 = 21
        case closedEyes = 25
        case drink = 28
        case crying = 18
        case sticker14 = 14
        case zzz = 26
        case sticker27 = 27
    }

    var buttonOnClick: (() -> ())?

    let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(libraryNamed: "mascot"))
        imageView.isHidden = true
        
        return imageView
    }()
    
    let avatarView = AvatarView()

    let captionView: UILabel = {
        let captionView = UILabel()
        captionView.textColor = .sfTextSecondary
        captionView.numberOfLines = 0
        captionView.font = SFPalette.font
        captionView.textAlignment = .center
        
        return captionView
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = SFPalette.font
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 20.0
        button.isHidden = true
        
        return button
    }()

    var userId: Int64 {
        didSet {
            updateAvatarView()
        }
    }

    init(userId: Int64) {
        self.userId = userId
        super.init(frame: .zero)
        
        addSubview(avatarView)
        addSubview(captionView)
        addSubview(actionButton)
        addSubview(placeholderImageView)

        actionButton.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
         
        bindEvents()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if shouldFade, alpha == 0.0 {
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1.0
            }
        }
    }
    
}

// MARK: - Private methods
fileprivate extension PlaceholderView {
    
    func setupConstraints() {
        avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(AvatarView.Layout.avatarImageViewHeight)
        }
        
        captionView.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(24.0)
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(captionView.snp.bottom).offset(16.0)
            make.centerX.equalToSuperview()
            make.width.equalTo(200.0)
            make.height.equalTo(40.0)
            make.bottom.equalToSuperview().offset(-24.0)
        }
        
        placeholderImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(AvatarView.Layout.avatarImageViewHeight)
        }
    }
    
    func bindEvents() {
//        NotificationCenter.default.addObserver(self, selector: #selector(layersDidUpdate), name: .profileEditNewLayers, object: nil)
    }
    
    func updateAvatarView() {
//        guard let userLayers = UserSettings.layers else {
//            return
//        }
//
//        let layers = "s"  + String(describing: stickerId.rawValue) + ";" + userLayers
        StickerLoader.loadSticker(into: avatarView.avatarImageView)
    }
    
    @objc func layersDidUpdate() {
        updateAvatarView()
    }
    
    @objc func buttonDidPress(_ sender: UIButton) {
//        Animations.press(view: sender)
        
        if let buttonOnClick = self.buttonOnClick {
            buttonOnClick()
        }
    }
    
}

class FCKeyboardManager: NSObject {
    var keyBoardHeight: CGFloat = 0
    var keyboardFrame: CGRect = .zero
    var isShown: Bool {
        get {
            return keyboardFrame != .zero
        }
    }

    static var shared = FCKeyboardManager()

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
}

fileprivate extension FCKeyboardManager {
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        keyboardFrame = keyboardRect
        keyBoardHeight = keyboardRect.height
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        keyboardFrame = .zero
    }
}
