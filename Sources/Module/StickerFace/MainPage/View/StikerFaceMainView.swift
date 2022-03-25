import UIKit

class StikerFaceMainView: RootView {
    
    let nftStoreView: NFTStoreView = {
        let view = NFTStoreView()
        
        return view
    }()
    
    override func setup() {
        backgroundColor = .white
        
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 23
        layer.cornerCurve = .continuous
        
        addSubview(nftStoreView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        nftStoreView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.0)
            make.left.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().offset(-16.0)
        }
    }
    
}
