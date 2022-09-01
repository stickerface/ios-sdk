import UIKit

class LayerColorSelectorEmbeddedCell: UICollectionViewCell {
        
    let colorSelectionIndicatorView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "colorSelectionIndicator")
        
        return view
    }()
    
    let collectionView: UICollectionView = {
        let layout = PagingFlowLayout()
        layout.zoomFactor = 0.2
        layout.activeDistance = 10
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(collectionView)
        contentView.addSubview(colorSelectionIndicatorView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if collectionView.contentInset == .zero {
            let cellSide = 52.0
            let offset = (bounds.width - cellSide) / 2
            collectionView.contentInset = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: offset)
        }
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-16.0)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.bottom.equalToSuperview()
        }
        
        colorSelectionIndicatorView.snp.makeConstraints { make in
            make.size.equalTo(60.0)
            make.centerX.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
}
