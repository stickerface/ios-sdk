import UIKit

class StikerFaceMainView: RootView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        
        return view
    }()
    
    let exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Export stickers", for: .normal)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 12.0
        
        return button
    }()
        
    override func setup() {
        backgroundColor = .white
        
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 23
        layer.cornerCurve = .continuous
        
        addSubview(collectionView)
        addSubview(exportButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        exportButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32.0)
            make.right.equalToSuperview().offset(-32.0)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-1)
            make.height.equalTo(49.0)
        }
    }
    
}
