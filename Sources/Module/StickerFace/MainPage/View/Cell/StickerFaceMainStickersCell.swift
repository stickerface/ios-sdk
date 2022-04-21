import UIKit

class StickerFaceMainStickersCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "placeholder_sticker_200")
        view.backgroundColor = .clear
        view.tintColor = UIColor.black.withAlphaComponent(0.06)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.borderColor = UIColor.sfSeparatorLight.cgColor
        layer.borderWidth = 1
        
        addSubview(imageView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
