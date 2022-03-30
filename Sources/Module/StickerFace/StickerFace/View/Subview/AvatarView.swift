import UIKit
import SnapKit

class AvatarView: UIView {
    
    enum Layout {
        static let avatarImageViewHeight: CGFloat = 207.0
    }
    
    let avatarImageView = UIImageView()
    let avatarClosedEyesImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(avatarImageView)
        addSubview(avatarClosedEyesImageView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarClosedEyesImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
}
