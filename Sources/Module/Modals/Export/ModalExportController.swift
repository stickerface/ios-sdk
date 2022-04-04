import UIKit

class ModalExportController: ModalScrollViewController {
    
    let exportView = ModalExportView()
    var layers = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(exportView)
        
        setupImages()
        setupArrangedViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    // MARK: Private actions
    
    private lazy var telegramExportAction: Action = { [weak self] in
        guard let self = self else { return }
        
    }

    private lazy var keyboardExportAction: Action = { [weak self] in
        guard let self = self else { return }
        
    }
    
    // MARK: Private methods
    
    private func setupArrangedViews() {
        addArrangedView(title: "Telegram",
                        image: UIImage(libraryNamed: "telegram"),
                        action: telegramExportAction)
        addArrangedView(title: "WhatsApp",
                        image: UIImage(libraryNamed: "share_whatsapp"),
                        action: nil)
        addArrangedView(title: "Keyboard",
                        image: UIImage(libraryNamed: "export_keyboard"),
                        action: keyboardExportAction)
    }
    
    private func addArrangedView(title: String, image: UIImage?, action: Action?) {
        let view = ModalShareArrangedView()
        view.imageView.image = image
        view.titleLabel.text = title
        view.action = action
        
        exportView.shareStackView.addArrangedSubview(view)
    }
    
    private func setupImages() {
        let firstLayers = "s3;" + layers
        ImageLoader.setImage(layers: firstLayers, imgView: exportView.leftImageView, outlined: false, size: 248)
        
        let secondLayers = "s15;" + layers
        ImageLoader.setImage(layers: secondLayers, imgView: exportView.centerImageView, outlined: false, size: 248)
        
        let thirdLayers = "s27;" + layers
        ImageLoader.setImage(layers: thirdLayers, imgView: exportView.rightImageView, outlined: false, size: 248)
    }
    
    private func layout() {
        exportView.pin
            .below(of: hideIndicatorView).marginTop(12.0)
            .left()
            .width(contentWidth)
        
        exportView.layoutIfNeeded()
        
        contentHeight = exportView.containerView.bounds.height
    }
    
}
