import UIKit

class StickerFaceMainMintCell: UICollectionViewCell {
    
    static func cellSize(containerSize: CGSize) -> CGSize {
        return CGSize(width: containerSize.width, height: 136.0)
    }
    
    let iamgeView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "temporary_mint")
        view.contentMode = .scaleAspectFit
        
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
    
    // TODO: оффсеты не по дизайну (сделаны для того чтобы картинка была как в дизайне)
    private func setupConstraints() {
        iamgeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16.0)
        }
    }
    
}
