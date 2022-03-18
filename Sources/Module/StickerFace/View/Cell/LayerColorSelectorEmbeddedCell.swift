import UIKit

class LayerColorSelectorEmbeddedCell: UICollectionViewCell {
    
    let colorSelectionIndicatorView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(libraryNamed: "colorSelectionIndicator")?.withRenderingMode(.alwaysTemplate)

        return imageView
    }()
    
    let collectionViewLayout: PagingFlowLayout = {
        let collectionViewLayout = PagingFlowLayout()
        collectionViewLayout.zoomFactor = 0.2
        collectionViewLayout.activeDistance = 10
        
        return collectionViewLayout
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        let width = 40.0
        let offset = (bounds.width - width) / 2
        view.contentInset = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: offset)
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
//        view.decelerationRate = .fast
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(collectionView)
        contentView.addSubview(colorSelectionIndicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
        collectionView.frame = bounds
        colorSelectionIndicatorView.pin.size(60).hCenter().vCenter()
    }
    
}
