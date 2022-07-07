import UIKit
import Atributika

class OnboardingView: RootView {

    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "onboardingAvatars")
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = SFPalette.fontBold.withSize(35)
        label.textColor = .sfTextPrimary
        label.text = "onboardingTitle".libraryLocalized
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
            .foregroundColor(UIColor.sfTextPrimary)
            .font(SFPalette.fontMedium.withSize(16))
            
        label.attributedText = "onboardingSubtitle".libraryLocalized.styleAll(style)
    
        return label
    }()
    
    let policyLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.textAlignment = .center
        label.textColor = .sfTextSecondary
        label.numberOfLines = 0
        label.font = SFPalette.fontMedium.withSize(12)
        label.isEnabled = true
        label.isUserInteractionEnabled = true
        
        let a = Style("a")
            .underlineStyle(.single)
            .underlineColor(label.textColor)
        
        label.attributedText = "onboardingPrivacyPolicyAndRules".libraryLocalized.style(tags: a)
        
        return label
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("commonContinue".libraryLocalized, for: .normal)
        button.titleLabel?.font = SFPalette.fontBold.withSize(16.0)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 14.0
        
        return button
    }()
    
    override func setup() {
        backgroundColor = .white
        
        addSubview(imageView)
        addSubview(continueButton)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(policyLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(40.0)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(56.0)
            make.right.equalToSuperview().offset(-47.5)
            make.left.equalToSuperview().offset(47.5)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(7.0)
            make.right.equalToSuperview().offset(-32.0)
            make.left.equalToSuperview().offset(32.0)
        }
        
        policyLabel.snp.makeConstraints { make in
            make.bottom.equalTo(continueButton.snp.top).offset(-16.0)
            make.left.equalToSuperview().offset(52.0)
            make.right.equalToSuperview().offset(-52.0)
        }
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16.0)
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
            make.height.equalTo(48.0)
        }
    }
    
}
