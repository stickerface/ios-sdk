import UIKit
import WebKit

class StickerFaceView: RootView {

    let editorViewController = StickerFaceEditorViewController()
    
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
    
    let tonBalanceView: TonBalanceView = {
        let view = TonBalanceView()
        view.layer.cornerRadius = 16
         
        return view
    }()
    
    let rightTopButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 24.0
        button.setImage(UIImage(libraryNamed: "male"), for: .normal)
        button.tintColor = .sfAccentSecondary
        
        return button
    }()
    
    let rightBottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 24.0
        button.setImage(UIImage(libraryNamed: "hanger"), for: .normal)
        button.tintColor = .sfAccentSecondary
        
        return button
    }()
    
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    override func setup() {
        backgroundColor = .white
        
        addSubview(backgroundImageView)
        addSubview(tonBalanceView)
        addSubview(rightTopButton)
        addSubview(rightBottomButton)
        addSubview(renderWebView)
        addSubview(avatarView)
        addSubview(editorViewController.view)
        
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        editorViewController.view.frame = CGRect(x: 0, y: avatarView.frame.maxY, width: bounds.width, height: bounds.height - avatarView.frame.maxY)
    }
    
    private func setupConstraints() {
        tonBalanceView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.0)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8.0)
        }
        
        rightTopButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16.0)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8)
            make.size.equalTo(48.0)
        }
        
        rightBottomButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16.0)
            make.bottom.equalTo(avatarView.snp.bottom).offset(-16.0)
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
        
    }
    
}
