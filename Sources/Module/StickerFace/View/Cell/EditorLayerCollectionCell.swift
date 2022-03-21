import UIKit
import PinLayout
import SkeletonView

class EditorLayerCollectionCell: UICollectionViewCell {
    
    let layerImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 16.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.sfSeparatorLight.cgColor
        view.isSkeletonable = true
        
        return view
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
    
    let checkmarkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "small_cirle_checkmark")
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                    
        contentView.addSubview(layerImageView)
        contentView.addSubview(coinsButton)
        
        layerImageView.addSubview(checkmarkImageView)
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
    
    // MARK: Public methods
    
    func setSelected(_ isSelected: Bool) {
        checkmarkImageView.isHidden = !isSelected
        layerImageView.layer.borderColor = isSelected ?
        UIColor.sfAccentBrand.cgColor :
        UIColor.sfSeparatorLight.cgColor
    }
    
    private func layout() {
                
        let titleWidth = coinsButton.title(for: .normal)?.size(withAttributes: [.font: Palette.fontBold.withSize(14.0)]).width ?? 0.0
        
        coinsButton.pin
            .bottom()
            .hCenter()
            .height(22.0)
            .width(titleWidth + 20.0)
        
        layerImageView.pin
            .top()
            .hCenter()
            .size(frame.width - coinsButton.frame.height)
        
        checkmarkImageView.pin
            .bottom(12)
            .right(12)
            .size(18)
    }
    
}
