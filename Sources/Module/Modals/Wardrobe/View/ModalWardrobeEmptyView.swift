import UIKit

class ModalWardrobeEmptyView: RootView {

    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "laundry")
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    // TODO: add attributed label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "All NFTs’ purchases will\nbe stored here"
        label.font = Palette.fontMedium.withSize(14)
        label.textColor = .sfTextSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    override func setup() {
        backgroundColor = .clear
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        setupConstraints()
    }
    
    // TODO: решить что с размерами
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(146.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(80.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16.0)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-146.0)
        }
    }

}
