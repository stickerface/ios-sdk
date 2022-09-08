import UIKit
import SnapKit

public class AvatarView: UIView {
    
    public enum Layout {
        public static let avatarImageViewHeight: CGFloat = 207.0
    }
    
    public let avatarClosedEyesImageView = UIImageView()
    
    public let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(libraryNamed: "placeholder_sticker_200")
        view.tintColor = .black.withAlphaComponent(0.06)
        
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(avatarImageView)
        addSubview(avatarClosedEyesImageView)
        
        setupConstraints()
        showAvatarEyes()
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
    
    @objc private func showAvatarEyes() {
        avatarClosedEyesImageView.isHidden = true
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(hideAvatarEyes), with: nil, afterDelay: Double.random(in: 3.0...5.0))
    }

    @objc private func hideAvatarEyes() {
        avatarClosedEyesImageView.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(showAvatarEyes), with: nil, afterDelay: 0.1)
    }
    
}
