import UIKit
import Atributika

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
        label.textColor = .textPrimary
        label.text = "connectWalletTitle".libraryLocalized
        label.textAlignment = .center
        
        return label
    }()
    
    let subtitleLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.numberOfLines = 0
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let style = Style()
            .paragraphStyle(paragraphStyle)
            .foregroundColor(UIColor.textPrimary)
            .font(Palette.fontMedium.withSize(16))

        label.attributedText = "connectWalletSubtitle".libraryLocalized.styleAll(style)
        
        return label
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("connectWalletWithoutWallet".libraryLocalized, for: .normal)
        button.titleLabel?.font = Palette.fontSemiBold.withSize(16.0)
        button.setTitleColor(.accentBrand, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14.0
        
        return button
    }()
    
    let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("connectWalletConnectTitle".libraryLocalized, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.setTitleColor(.defaultWhite, for: .normal)
        button.backgroundColor = .accentBrand
        button.layer.cornerRadius = 14.0
        button.setImage(UIImage(libraryNamed: "tonkeeper_1"), for: .normal)
        button.tintColor = .white
        
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
