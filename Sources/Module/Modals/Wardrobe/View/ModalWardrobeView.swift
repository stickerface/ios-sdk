import UIKit

class ModalWardrobeView: RootView {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "wardrobeTitle".libraryLocalized
        label.font = SFPalette.fontBold.withSize(20)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "wardrobeSubtitle".libraryLocalized
        label.font = SFPalette.fontMedium.withSize(16)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    override func setup() {
        backgroundColor = .white
        layer.cornerRadius = 23
        
        addSubview(containerView)
        addSubview(bottomView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
        let collectionHeight: CGFloat
        
        if UserSettings.wardrobe.isEmpty {
            collectionHeight = 90.0 + 136.0 + 146.0 + 34.0
        } else {
            let linesCount = (CGFloat(UserSettings.wardrobe.count) / 2.0).rounded(.up)
            let contentHeight = linesCount * 188.0 + (linesCount - 1) * 12 + 50
            let maxHeight = UIScreen.main.bounds.height - Utils.safeArea().top - 24.0 - 104.0
            collectionHeight = min(contentHeight, maxHeight)
        }
        
        containerView.pin
            .left()
            .right()
            .top()
        
        titleLabel.pin
            .top(24.0)
            .left()
            .right()
            .sizeToFit(.width)
        
        subtitleLabel.pin
            .top(to: titleLabel.edge.bottom).marginTop(8.0)
            .left()
            .right()
            .sizeToFit(.width)
        
        collectionView.pin
            .top(to: titleLabel.edge.bottom).marginTop(56.0)
            .left()
            .right()
            .height(collectionHeight)
        
        bottomView.pin
            .top(to: collectionView.edge.bottom)
            .left()
            .right()
            .height(UIScreen.main.bounds.height)
        
        containerView.pin.height(collectionView.frame.maxY)
        pin.height(bottomView.frame.maxY)
    }
    
}
