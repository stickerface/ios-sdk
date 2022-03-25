import UIKit
import Atributika

class NFTStoreView: UIView {

    let titleLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.17
        
        let style = Style()
            .font(Palette.fontBold.withSize(14))
            .foregroundColor(UIColor.sfAccentSecondary)
            .paragraphStyle(paragraphStyle)

        label.attributedText = "NFTs’ clothes\nand accessories".styleAll(style)
        
        return label
    }()
    
    let storeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.backgroundColor = .sfAccentBrand
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.setTitle("Go to store", for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(12)
        button.contentEdgeInsets = UIEdgeInsets(top: 13, left: 19.5, bottom: 13, right: 19.5)
        
        return button
    }()
    
    let backAvatarImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "store_preview1")
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    let frontAvatarImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "store_preview2")
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.sfSeparatorLight.cgColor
        
        addSubview(titleLabel)
        addSubview(storeButton)
        addSubview(backAvatarImageView)
        addSubview(frontAvatarImageView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.0)
            make.left.equalToSuperview().offset(16.0)
        }
        
        storeButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20.0)
            make.left.equalToSuperview().offset(16.0)
            make.bottom.equalToSuperview().offset(-16.0)
            make.height.equalTo(40.0)
        }
        
        backAvatarImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14.0)
            make.bottom.equalToSuperview()
        }
        
        frontAvatarImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-61.0)
            make.bottom.equalToSuperview()
        }
    }

    
}
