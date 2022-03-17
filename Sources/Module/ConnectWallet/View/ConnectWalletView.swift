import UIKit

class ConnectWalletView: RootView {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "onboardingDiamond")
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Palette.fontBold.withSize(35)
        label.textColor = .sfTextPrimary
        label.text = "Connect your crypto wallet"
        label.textAlignment = .center
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        label.attributedText = NSMutableAttributedString(
            string: "To continue you need to have a cryptocurrency wallet Tonkeeper",
            attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.sfTextPrimary,
                .font: Palette.fontMedium.withSize(16)
            ]
        )
        
        return label
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue without wallet", for: .normal)
        button.titleLabel?.font = Palette.fontSemiBold.withSize(16.0)
        button.setTitleColor(.sfAccentBrand, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14.0
        
        return button
    }()
    
    let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Connect with Tonkeeper", for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 14.0
        button.setImage(UIImage(libraryNamed: "tonkeeper_1"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: -1.0, left: -7.0, bottom: 0.0, right: 7.0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -2.0, bottom: 0.0, right: 0.0)
        
        return button
    }()
    
    override func setup() {
        backgroundColor = .white
        
        addSubview(imageView)
        addSubview(continueButton)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(connectButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            let topOffset = (UIScreen.main.bounds.height - Utils.safeAreaVertical()) * 0.20
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(topOffset)
            make.centerX.equalToSuperview()
            make.size.equalTo(104)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24.0)
            make.right.equalToSuperview().offset(-47.5)
            make.left.equalToSuperview().offset(47.5)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(7.0)
            make.right.equalToSuperview().offset(-47.5)
            make.left.equalToSuperview().offset(47.5)
        }
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(connectButton.snp.top).offset(-8.0)
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
            make.height.equalTo(48.0)
        }
        
        connectButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16.0)
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
            make.height.equalTo(48.0)
        }
        
    }
    
}
