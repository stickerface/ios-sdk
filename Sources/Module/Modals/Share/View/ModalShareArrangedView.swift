import UIKit

class ModalShareArrangedView: RootView {

    var action: Action?
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = SFPalette.fontMedium.withSize(12)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    override func setup() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(gesture)
        
        setupConstraints()
    }
    
    @objc private func viewTapped() {
        action?()
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.size.equalTo(64.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8.0)
            make.bottom.equalToSuperview()
            make.right.left.equalToSuperview()
        }
    }
    
}
