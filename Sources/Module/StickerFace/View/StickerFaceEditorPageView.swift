import UIKit

class StickerFaceEditorPageView: RootView {
    
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 116.0, right: 0.0)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = UIColor(libraryNamed: "stickerFaceBackgroundMain")
        
        return view
    }()
    
    override func setup() {
        
        backgroundColor = UIColor(libraryNamed: "stickerFaceBackgroundSystem")

        addSubview(collectionView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
