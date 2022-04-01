import UIKit

class ModalShareController: ModalScrollViewController {
    
    let shareView = ModalShareView()
    let shareImage: UIImage?
    
    init(shareImage: UIImage?) {
        self.shareImage = shareImage
        super.init()
        
        shareView.imageView.image = shareImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(shareView)
        
        setupArrangedViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    // MARK: Private actions
    
    private lazy var telegramShareAction: Action = { [weak self] in
        guard let self = self else { return }
        
    }
    
    private lazy var otherShareAction: Action = { [weak self] in
        guard let self = self else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [self.shareImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Private methods
    
    private func setupArrangedViews() {
        addArrangedView(title: "Telegram",
                        image: UIImage(libraryNamed: "telegram"),
                        action: telegramShareAction)
        addArrangedView(title: "Facebook",
                        image: UIImage(libraryNamed: "share_fb"),
                        action: nil)
        addArrangedView(title: "WhatsApp",
                        image: UIImage(libraryNamed: "share_whatsapp"),
                        action: nil)
        addArrangedView(title: "Other",
                        image: UIImage(libraryNamed: "share_other"),
                        action: otherShareAction)
    }
    
    private func addArrangedView(title: String, image: UIImage?, action: Action?) {
        let view = ModalShareArrangedView()
        view.imageView.image = image
        view.titleLabel.text = title
        view.action = action
        
        shareView.shareStackView.addArrangedSubview(view)
    }
    
    private func layout() {
        shareView.pin
            .below(of: hideIndicatorView).marginTop(12.0)
            .left()
            .width(contentWidth)
        
        shareView.layoutIfNeeded()
        
        contentHeight = shareView.bounds.height
    }
    
}
