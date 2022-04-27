import UIKit

class ModalShareController: ModalScrollViewController {
    
    let mainView = ModalShareView()
    let shareImage: UIImage?
    
    init(shareImage: UIImage?) {
        self.shareImage = shareImage
        super.init()
        
        mainView.imageView.image = shareImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(mainView)
        
        setupArrangedViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    // MARK: Private actions
    
    private lazy var telegramShareAction: Action = { [weak self] in
        guard let self = self else { return }
        let pb: UIPasteboard = UIPasteboard.general
        pb.image = self.shareImage
        
        let urlString = "tg://msg?text="
        let tgUrl = URL.init(string:urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        if UIApplication.shared.canOpenURL(tgUrl!) {
            UIApplication.shared.open(tgUrl!)
        }
    }
    
    private lazy var otherShareAction: Action = { [weak self] in
        guard let self = self, let image = self.shareImage else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Private methods
    
    private func setupArrangedViews() {
//        addArrangedView(title: "Telegram",
//                        image: UIImage(libraryNamed: "telegram"),
//                        action: telegramShareAction)
//        addArrangedView(title: "Facebook",
//                        image: UIImage(libraryNamed: "share_fb"),
//                        action: nil)
//        addArrangedView(title: "WhatsApp",
//                        image: UIImage(libraryNamed: "share_whatsapp"),
//                        action: nil)
        addArrangedView(title: "commonOther".libraryLocalized,
                        image: UIImage(libraryNamed: "share_other"),
                        action: otherShareAction)
    }
    
    private func addArrangedView(title: String, image: UIImage?, action: Action?) {
        let view = ModalShareArrangedView()
        view.imageView.image = image
        view.titleLabel.text = title
        view.action = action
        
        mainView.shareStackView.addArrangedSubview(view)
    }
    
    private func layout() {
        mainView.pin
            .below(of: hideIndicatorView).marginTop(12.0)
            .left()
            .width(contentWidth)
        
        mainView.layoutIfNeeded()
        
        contentHeight = mainView.containerView.bounds.height
    }
    
}
