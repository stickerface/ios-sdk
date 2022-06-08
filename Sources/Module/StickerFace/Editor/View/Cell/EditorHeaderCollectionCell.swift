import UIKit
import PinLayout

class EditorHeaderCollectionCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = SFPalette.fontSemiBold.withSize(16)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    let selectedIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .sfAccentSecondary
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
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.height(size.height)
        layout()
        
        return contentView.frame.size
    }
    
    private func layout() {
        
        titleLabel.pin
            .left(16.0)
            .top(17.0)
            .sizeToFit(.widthFlexible)

        selectedIndicatorView.pin
            .height(2.0)
            .left(to: titleLabel.edge.left)
            .right(to: titleLabel.edge.right)
            .bottom()
        
        contentView.pin.width(titleLabel.frame.maxX + 16.0)
    }
    
}
