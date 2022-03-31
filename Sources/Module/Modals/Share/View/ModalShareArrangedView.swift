import UIKit

class ModalShareArrangedView: UIView {

    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Palette.fontMedium.withSize(12)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    init(image: UIImage?, text: String) {
        super.init(frame: .zero)
        
        imageView.image = image
        titleLabel.text = text
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
