import UIKit

class LayerColorSelectorEmbeddedCell: UICollectionViewCell {
        
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 12.0)
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(collectionView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-16.0)
            make.top.right.bottom.equalToSuperview()
        }
    }
    
}
