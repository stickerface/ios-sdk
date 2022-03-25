import UIKit

class StikerFaceMainView: RootView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        
        return view
    }()
        
    override func setup() {
        backgroundColor = .white
        
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 23
        layer.cornerCurve = .continuous
        
        addSubview(collectionView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
