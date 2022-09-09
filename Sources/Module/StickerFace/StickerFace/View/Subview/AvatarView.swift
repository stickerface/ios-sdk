import UIKit
import SnapKit

public class AvatarView: UIView {
    
    public enum Layout {
        public static let avatarImageViewHeight: CGFloat = 207.0
    }
        
    private let avatarClosedEyesImageView = UIImageView()
    
    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(libraryNamed: "placeholder_sticker_200")
        view.tintColor = .black.withAlphaComponent(0.06)
        
        return view
    }()
    
    public var avatar: SFAvatar? {
        didSet {
            guard let avatar = avatar else { return }
            update(avatar: avatar)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        addSubview(avatarImageView)
        addSubview(avatarClosedEyesImageView)
        
        setupConstraints()
        showAvatarEyes()
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarClosedEyesImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func update(avatar: SFAvatar) {
        if let personImage = avatar.personImage {
            avatarImageView.image = UIImage(data: personImage)
        }
        
        if let personLayers = avatar.personLayers {
            let size = frame.size.maxSide
            
            StickerLoader.shared.renderLayer(personLayers, size: size) { [weak self] image in
                self?.avatar?.personImage = image.pngData()
                self?.avatarImageView.image = image
            }
            
            StickerLoader.shared.renderLayer(Stickers.closedEyes.stringValue + personLayers, size: size) { [weak self] image in
                self?.avatarClosedEyesImageView.image = image
            }
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
