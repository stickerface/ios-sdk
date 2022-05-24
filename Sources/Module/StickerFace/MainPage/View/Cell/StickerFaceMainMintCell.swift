import UIKit

class StickerFaceMainMintCell: UICollectionViewCell {
    
    static func cellSize(containerSize: CGSize) -> CGSize {
        return CGSize(width: containerSize.width, height: 132.0)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.sfSeparatorLight.cgColor
        
        return view
    }()
    
    let comingSoonButton: UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = false
        button.backgroundColor = .sfAccentSecondary
        button.setTitle("Coming soon", for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(10)
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 6.0, bottom: 4.0, right: 6.0)
        button.layer.cornerRadius = 10.0
        
        return button
    }()
    
    let createLabel: UILabel = {
        let label = UILabel()
        label.text = "Create own NFT"
        label.font = Palette.fontBold.withSize(14)
        label.textColor = .sfTextPrimary
        label.alpha = 0.25
        
        return label
    }()
    
    let mintLabel: UILabel = {
        let label = UILabel()
        label.text = "Mint current avatar"
        label.font = Palette.fontMedium.withSize(14)
        label.textColor = .sfTextSecondary
        label.alpha = 0.25
        
        return label
    }()
    
    let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(libraryNamed: "placeholder_sticker_200")
        view.tintColor = .black.withAlphaComponent(0.06)
        view.layer.cornerRadius = 24
        view.alpha = 0.25
        
        return view
    }()
    
    let plusImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "mint_plus")
        view.alpha = 0.99
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        addSubview(comingSoonButton)
        
        containerView.addSubview(createLabel)
        containerView.addSubview(mintLabel)
        containerView.addSubview(avatarImageView)
        
        avatarImageView.addSubview(plusImageView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.0)
            make.left.right.equalToSuperview().inset(16.0)
            make.bottom.equalToSuperview().offset(-16.0)
        }
        
        comingSoonButton.snp.makeConstraints { make in
            make.left.equalTo(containerView.snp.left).offset(16.0)
            make.top.equalTo(containerView.snp.top).offset(16.0)
            make.height.equalTo(20.0)
        }
        
        createLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.0)
            make.bottom.equalTo(mintLabel.snp.top)
            make.height.equalTo(20.0)
        }
        
        mintLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16.0)
            make.left.equalToSuperview().offset(16.0)
            make.height.equalTo(20.0)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16.0)
            make.right.equalToSuperview().offset(-16.0)
            make.size.equalTo(48.0)
        }
        
        plusImageView.snp.makeConstraints { make in
            make.size.equalTo(20.0)
            make.bottom.right.equalToSuperview()
        }
    }
    
}
