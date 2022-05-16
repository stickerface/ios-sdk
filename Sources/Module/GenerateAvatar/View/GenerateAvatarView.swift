import UIKit

class GenerateAvatarView: RootView {
    
    let camera: SFCamera = {
        let camera = SFCamera()
        camera.previewLayer.alpha = 0
        camera.previewLayer.clipsToBounds = true
        
        return camera
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        label.font = Palette.fontBold.withSize(34.0)
        label.text = "setupAvatarTitle".libraryLocalized
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        label.font = Palette.fontMedium.withSize(16)
        label.text = "setupAvatarSubtitle".libraryLocalized
        label.numberOfLines = 0
        
        return label
    }()
    
    let onboardingAvatarVideoView = OnboardingAvatarVideoView()
    
    let linesRoundRotateAnimationView: LinesRoundRotateAnimationView = {
        let view = LinesRoundRotateAnimationView()
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    let avatarImageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "mvp_background")
        view.layer.cornerRadius = 280.0/2
        view.clipsToBounds = true
        view.alpha = 0
        
        return view
    }()
    
    let avatarPlaceholderView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "camera_72")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .sfAccentBrand
        
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "setupAvatarDescription".libraryLocalized
        label.textColor = .sfTextSecondary
        label.textAlignment = .center
        label.font = Palette.fontMedium.withSize(12)
        label.numberOfLines = 0
        
        return label
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.sfAccentBrand, for: .normal)
        button.setTitle("setupAvatarContinueTitle".libraryLocalized, for: .normal)
        button.titleLabel?.font = Palette.fontSemiBold.withSize(16.0)
        button.backgroundColor = .clear
        
        return button
    }()
    
    let allowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.setTitle("setupAvatarAllowTitle".libraryLocalized, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 14.0
        
        return button
    }()
    
    override func setup() {
        
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(avatarPlaceholderView)
        addSubview(camera.previewLayer)
        addSubview(onboardingAvatarVideoView)
        addSubview(linesRoundRotateAnimationView)
        addSubview(continueButton)
        addSubview(allowButton)
        addSubview(descriptionLabel)
        addSubview(backgroundImageView)
        addSubview(avatarImageView)
        
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        camera.previewLayer.frame = avatarImageView.frame
        camera.previewLayer.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    private func setupConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(32.0)
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16.0)
            make.left.equalToSuperview().offset(48.0)
            make.right.equalToSuperview().offset(-48.0)
        }
        
        avatarPlaceholderView.snp.makeConstraints { make in
            make.center.equalTo(onboardingAvatarVideoView)
            make.size.equalTo(72.0)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(avatarImageView.snp.edges)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.center.equalTo(linesRoundRotateAnimationView.snp.center)
            make.centerX.equalToSuperview()
            make.size.equalTo(280.0)
        }
        
        onboardingAvatarVideoView.snp.makeConstraints { make in
            make.center.equalTo(linesRoundRotateAnimationView.snp.center)
            make.centerX.equalToSuperview()
            make.size.equalTo(280.0)
        }
        
        linesRoundRotateAnimationView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(90.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(LinesRoundRotateAnimationView.Layout.side)
        }
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(allowButton.snp.top).offset(-8.0)
            make.right.equalToSuperview().offset(-32.0)
            make.left.equalToSuperview().offset(32)
            make.height.equalTo(48.0)
        }
        
        allowButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16.0)
            make.right.equalToSuperview().offset(-32.0)
            make.left.equalToSuperview().offset(32)
            make.height.equalTo(48.0)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48.0)
            make.right.equalToSuperview().offset(-48.0)
            make.bottom.equalTo(continueButton.snp.top).offset(-16.0)
        }
        
    }
    
}
