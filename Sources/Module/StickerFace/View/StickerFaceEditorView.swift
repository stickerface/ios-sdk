import UIKit
import SnapKit
import WebKit
import SkeletonView

class StickerFaceEditorView: RootView {
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    let renderWebView: WKWebView = {
        let webView = WKWebView()
        webView.alpha = 0
        
        return webView
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
    
    let avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.layer.masksToBounds = true
        
        return avatarView
    }()
        
    let headerCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.layer.cornerRadius = 23
        view.layer.cornerCurve = .continuous
        
        return view
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xE5E5EA)
        
        return view
    }()
        
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save and continue", for: .normal)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 12.0
        
        return button
    }()
    
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    let loaderView = LoaderView()

    override func setup() {
        
        backgroundColor = .white
        
        addSubview(backgroundImageView)
        addSubview(tonBalanceView)
        addSubview(rightTopButton)
        addSubview(rightBottomButton)
        addSubview(renderWebView)
        addSubview(avatarView)
        addSubview(headerCollectionView)
        addSubview(separator)
        addSubview(pageViewController.view)
        addSubview(saveButton)
        addSubview(loaderView)
        
        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        pageViewController.view.frame = CGRect(x: 0, y: separator.frame.maxY, width: bounds.width, height: bounds.height - separator.frame.maxY)
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
            make.bottom.equalTo(headerCollectionView.snp.top).offset(-16.0)
            make.size.equalTo(48.0)
        }
        
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(84.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(AvatarView.Layout.avatarImageViewHeight)
        }
        
        renderWebView.snp.makeConstraints { make in
            make.edges.equalTo(avatarView.snp.edges)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(headerCollectionView.snp.bottom)
        }
        
        headerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(50.0)
        }
        
        separator.snp.makeConstraints { make in
            make.top.equalTo(headerCollectionView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(1.0)
        }
        
        saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(48.0)
        }
        
    }

}
