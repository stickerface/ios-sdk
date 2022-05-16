import UIKit

class StickerFaceMainView: RootView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    let exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("mainExport".libraryLocalized, for: .normal)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 12.0
        
        return button
    }()
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let color1 = UIColor.white.cgColor
        let color2 = UIColor.white.cgColor
        let color3 = UIColor.white.withAlphaComponent(0).cgColor

        layer.colors = [color1, color2, color3]
        layer.locations = [0.0, 0.13, 1.0]
        
        return layer
    }()
    
    let gradientView: UIView = {
        let view = UIView()
        view.alpha = 0
        
        return view
    }()
        
    override func setup() {
        backgroundColor = .white
        
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 23
        layer.cornerCurve = .continuous
        
        addSubview(collectionView)
        addSubview(gradientView)
        addSubview(exportButton)
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = gradientView.bounds
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(40.0)
        }
        
        exportButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32.0)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-1)
            make.height.equalTo(49.0)
        }
    }
    
}
