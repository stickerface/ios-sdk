import UIKit

class StickerFaceMainStoreCell: UICollectionViewCell {

    static func cellSize(containerSize: CGSize) -> CGSize {
        return CGSize(width: containerSize.width, height: 148.0)
    }
    
    let nftStoreView: NFTStoreView = {
        let view = NFTStoreView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nftStoreView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        nftStoreView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview().inset(16.0)
        }
    }
    
}
