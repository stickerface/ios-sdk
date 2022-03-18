import UIKit
import PinLayout
import SkeletonView

class EditorLayerCollectionCell: UICollectionViewCell {
    
    let layerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        imageView.isSkeletonable = true
        
        return imageView
    }()
        
    let coinsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(libraryNamed: "coin_12"), for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(14.0)
        button.setTitleColor(UIColor(libraryNamed: "stickerFaceTextPrimary"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -8.0, bottom: 0.0, right: 0.0)
        button.isUserInteractionEnabled = false
        button.isHidden = true
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        contentView.layer.cornerRadius = 8.0
        contentView.isSkeletonable = true
        
        contentView.addSubview(layerImageView)
        contentView.addSubview(coinsButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coinsButton.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
                
        let titleWidth = coinsButton.title(for: .normal)?.size(withAttributes: [.font: Palette.fontBold.withSize(14.0)]).width ?? 0.0
        coinsButton.pin.bottom().hCenter().height(22.0).width(titleWidth + 20.0)
        
        layerImageView.pin.top().hCenter().size(frame.width - coinsButton.frame.height)
    }
    
}
