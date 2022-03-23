import UIKit

class StickerFaceEditorPageView: RootView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 116.0, right: 16.0)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = UIColor(libraryNamed: "stickerFaceBackgroundMain")
        
        return view
    }()
    
    override func setup() {
        
        backgroundColor = .white

        addSubview(collectionView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
