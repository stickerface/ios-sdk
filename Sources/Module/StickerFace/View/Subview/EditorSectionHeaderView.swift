import UIKit

class EditorSectionHeaderView: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(libraryNamed: "stickerFaceTextSecondary")
        label.font = Palette.fontBold.withSize(14.0)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
        titleLabel.pin.top().bottom().left(20.0).right(20.0)
    }
    
}
