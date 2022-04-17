import UIKit

// TODO: Translate
class TonBalanceView: UIView {

    enum BalanceType {
        case disconnected
        case connected(ton: Double)
    }
    
    var balanceType: BalanceType = .disconnected {
        didSet {
            switch balanceType {
            case .disconnected:
                titleLabel.text = "Tonkeeper"
                subtitleLabel.text = "commonConnect".libraryLocalized
                
            case .connected(let ton):
                titleLabel.text = "commonBalance".libraryLocalized
                subtitleLabel.text = "\(ton) TON"
            }
        }
    }
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "tonkeeper_1")
        view.tintColor = .sfAccentBrand
        
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
        label.textColor = .sfTextSecondary
        label.font = Palette.fontMedium.withSize(10)
        label.textAlignment = .left
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "commonConnect".libraryLocalized
        label.textColor = .sfTextPrimary
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
