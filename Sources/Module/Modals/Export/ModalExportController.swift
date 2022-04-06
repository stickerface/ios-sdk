import UIKit
import TelegramStickersImport

class ModalExportController: ModalScrollViewController {
    
    let exportView = ModalExportView()
    var layers = ""
    var isLoading = false
    let emojis = [
        "☺️", "😰", "😱", "👌",
        "😡", "😘", "🤑", "🫵",
        "🖕", "🤘", "😬", "😂",
        "😅", "🤔", "😎", "😭",
        "🤦‍♂️", "😢", "👍", "👋",
        "🤷‍♂️", "🙅‍♂️", "😠", "🤯",
        "😑", "😴", "😇", "🍷",
        "🫣"
    ]
    
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
        guard let self = self, !self.isLoading else { return }
        
        self.isLoading = true
        let stickerSet = StickerSet(software: "Example Software", type: .image)
        let tmpImageView = UIImageView()
        let path = "http://sticker.face.cat/api/png/"
        
        for i in 0...28 {
            let url = path + "s\(i + 1);\(self.layers)?outline=true"
            ImageLoader.shared.loadImage(url: url as NSString) { image in
                if let stickerData = Sticker.StickerData(image: image) {
                    try? stickerSet.addSticker(
                        data: stickerData,
                        emojis: [self.emojis[i]]
                    )
                }
                
                if stickerSet.stickers.count == 28 {
                    try? stickerSet.import()
                    self.isLoading = false
                }
            }
        }
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
        ImageLoader.setImage(layers: firstLayers, imgView: exportView.leftImageView, outlined: true, size: 248)
        
        let secondLayers = "s15;" + layers
        ImageLoader.setImage(layers: secondLayers, imgView: exportView.centerImageView, outlined: true, size: 248)
        
        let thirdLayers = "s27;" + layers
        ImageLoader.setImage(layers: thirdLayers, imgView: exportView.rightImageView, outlined: true, size: 248)
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
