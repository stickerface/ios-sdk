import UIKit
import WebKit

class StickerFaceView: RootView {

    let editorViewController = StickerFaceEditorViewController()
    let mainViewController = StickerFaceMainViewController()
    
    let renderWebView: WKWebView = {
        let webView = WKWebView()
        webView.alpha = 0
        
        return webView
    }()
    
    let avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.layer.masksToBounds = true
        
        return avatarView
    }()
    
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.isSkeletonable = true
        
        return view
    }()
        
    let blurEffect: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        
        return blurView
    }()
        
    let tonBalanceView: TonBalanceView = {
        let view = TonBalanceView()
        view.layer.cornerRadius = 16
         
        return view
    }()
    
    let rightTopButton: AvatarButton = {
        let button = AvatarButton(imageType: .male)
        button.layer.cornerRadius = 24.0
        
        return button
    }()
    
    let editButton: AvatarButton = {
        let button = AvatarButton(imageType: .edit, type: .custom)
        button.layer.cornerRadius = 24.0
        
        return button
    }()
    
    let hangerButton: AvatarButton = {
        let button = AvatarButton(imageType: .hanger)
        button.layer.cornerRadius = 24.0
        
        return button
    }()
    
    let backButton: AvatarButton = {
        let button = AvatarButton(imageType: .back)
        button.layer.cornerRadius = 24.0
        button.isHidden = true
        
        return button
    }()
    
    override func setup() {
        backgroundColor = .white
        
        addSubview(backgroundImageView)
        addSubview(tonBalanceView)
        addSubview(rightTopButton)
        addSubview(editButton)
        addSubview(hangerButton)
        addSubview(backButton)
        addSubview(renderWebView)
        addSubview(avatarView)
        addSubview(editorViewController.view)
        addSubview(mainViewController.view)
        
        backgroundImageView.addSubview(blurEffect)
        
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        editorViewController.view.frame = CGRect(x: 0, y: avatarView.frame.maxY, width: bounds.width, height: bounds.height - avatarView.frame.maxY)
        mainViewController.view.frame = CGRect(x: 0, y: avatarView.frame.maxY, width: bounds.width, height: bounds.height - avatarView.frame.maxY)
    }
    
    private func setupConstraints() {
        tonBalanceView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.0)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8.0)
        }
        
        rightTopButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16.0)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8.0)
            make.size.equalTo(48.0)
        }
        
        editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16.0)
            make.top.equalTo(rightTopButton.snp.bottom).offset(16.0)
            make.size.equalTo(48.0)
        }
        
        hangerButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16.0)
            make.bottom.equalTo(avatarView.snp.bottom).offset(-16.0)
            make.size.equalTo(48.0)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.0)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8.0)
            make.size.equalTo(48.0)
        }
        
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(85.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(AvatarView.Layout.avatarImageViewHeight)
        }
        
        renderWebView.snp.makeConstraints { make in
            make.edges.equalTo(avatarView.snp.edges)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(avatarView.snp.bottom).offset(12.0)
        }
        
        blurEffect.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
}
