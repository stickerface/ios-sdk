import UIKit
import TelegramStickersImport

class ModalExportController: ModalScrollViewController {
    
    let mainView = ModalExportView()
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
        
        scrollView.addSubview(mainView)
        
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
        let stickerSet = StickerSet(software: "StickerFace", type: .image)
        let path = StickerLoader.avatarPath
        
        for i in 0...28 {
            let url = path + "s\(i + 1);\(self.layers)"
            StickerLoader.shared.loadImage(url: url) { image in
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
        addArrangedView(title: "commonKeyboard".libraryLocalized,
                        image: UIImage(libraryNamed: "export_keyboard"),
                        action: keyboardExportAction)
    }
    
    private func addArrangedView(title: String, image: UIImage?, action: Action?) {
        let view = ModalShareArrangedView()
        view.imageView.image = image
        view.titleLabel.text = title
        view.action = action
        
        mainView.shareStackView.addArrangedSubview(view)
    }
    
    private func setupImages() {
        let firstLayers = "s3;" + layers
        StickerLoader.loadSticker(into: mainView.leftImageView, with: firstLayers)
        
        let secondLayers = "s15;" + layers
        StickerLoader.loadSticker(into: mainView.centerImageView, with secondLayers)
        
        let thirdLayers = "s27;" + layers
        StickerLoader.loadSticker(into: mainView.rightImageView, with: thirdLayers)
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
