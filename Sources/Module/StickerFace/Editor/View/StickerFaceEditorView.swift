import UIKit
import SnapKit
import WebKit
import SkeletonView

class StickerFaceEditorView: RootView {
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
    let rightGradientView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "sections_fade_right")
        view.backgroundColor = .clear
        
        return view
    }()
    
    let leftGradientView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "sections_fade_left")
        view.backgroundColor = .clear
        view.alpha = 0
        
        return view
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
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xE5E5EA)
        
        return view
    }()
        
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("editorSave".libraryLocalized, for: .normal)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.titleLabel?.font = SFPalette.fontBold.withSize(16.0)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 12.0
        
        return button
    }()
    
    //TODO: TRANSLATE
    let notConnectLabel: UILabel = {
        let label = UILabel()
        label.font = SFPalette.fontBold.withSize(24.0)
        label.text = "Cannot connect to the StickerFace."
        label.textColor = .sfTextPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    //TODO: TRANSLATE
    let notConnectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(.sfAccentBrand, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = SFPalette.fontBold.withSize(16.0)
        button.isHidden = true
        
        return button
    }()
    
    let loaderView: LoaderView = {
        let view = LoaderView()
        view.isHidden = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 23
        view.layer.cornerCurve = .circular
        
        return view
    }()

    override func setup() {
        backgroundColor = .clear
        
        addSubview(headerCollectionView)
        addSubview(rightGradientView)
        addSubview(leftGradientView)
        addSubview(separator)
        addSubview(pageViewController.view)
        addSubview(saveButton)
        addSubview(notConnectLabel)
        addSubview(notConnectButton)
        addSubview(loaderView)
        
        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        pageViewController.view.frame = CGRect(x: 0, y: separator.frame.maxY, width: bounds.width, height: bounds.height - separator.frame.maxY)
    }
    
    private func setupConstraints() {
        headerCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(51.0)
        }
        
        rightGradientView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalTo(headerCollectionView.snp.height)
        }
        
        leftGradientView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalTo(headerCollectionView.snp.height)
        }
        
        separator.snp.makeConstraints { make in
            make.top.equalTo(headerCollectionView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(1.0)
        }
        
        saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-1)
            make.height.equalTo(49.0)
        }
        
        notConnectLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-50.0)
            make.left.right.equalToSuperview().inset(24.0)
        }
        
        notConnectButton.snp.makeConstraints { make in
            make.top.equalTo(notConnectLabel.snp.bottom).offset(12.0)
            make.height.equalTo(48.0)
            make.centerX.equalTo(notConnectLabel.snp.centerX)
        }
        
        loaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
