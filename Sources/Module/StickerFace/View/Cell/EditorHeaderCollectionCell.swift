import UIKit
import PinLayout

class EditorHeaderCollectionCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Palette.fontSemiBold
        label.textColor = UIColor(libraryNamed: "stickerFaceTextPrimary")
        label.textAlignment = .center
        
        return label
    }()
    
    let selectedIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(libraryNamed: "stickerFaceAccent")
        view.layer.cornerRadius = 1.0
        view.isHidden = true
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectedIndicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
        
        titleLabel.pin.left(16.0).top(16.0).bottom(16.0).sizeToFit(.widthFlexible)
        
        selectedIndicatorView.pin.height(2.0).left().right().bottom()
        
        contentView.pin.width(titleLabel.frame.maxX + 16.0)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.height(size.height)
        layout()
        
        return contentView.frame.size
    }
    
}
