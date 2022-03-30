import UIKit

// TODO: Translate
// TODO: add state for connected wallet
// TODO: add color to palette colors
class TonBalanceView: UIView {

    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "tonkeeper_1")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor(hex: 0x45AEF5)
        
        return view
    }()
    
    let labelStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 1.0
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tonkeeper"
        label.textColor = UIColor(hex: 0x838A96)
        label.font = Palette.fontMedium.withSize(10)
        label.textAlignment = .left
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect"
        label.textColor = UIColor(hex: 0x151C29)
        label.font = Palette.fontBold.withSize(12)
        label.textAlignment = .left
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(imageView)
        addSubview(labelStack)
        
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(subtitleLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14.0)
            make.centerY.equalToSuperview()
            make.size.equalTo(26.0)
        }
        
        labelStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(11.0)
            make.bottom.equalToSuperview().offset(-11.0)
            make.right.equalToSuperview().offset(-16.0)
            make.left.equalTo(imageView.snp.right).offset(7.5)
        }
    }
}
