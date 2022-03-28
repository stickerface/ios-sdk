import UIKit

class StickerFaceMainMintCell: UICollectionViewCell {
    
    static func cellSize(containerSize: CGSize) -> CGSize {
        return CGSize(width: containerSize.width, height: 148.0)
    }
    
    let iamgeView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "temporary_mint")
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iamgeView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        iamgeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.0)
            make.left.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().offset(-16.0)
        }
    }
    
}
