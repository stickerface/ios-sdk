import UIKit

class AvatarButton: UIButton {

    enum ImageType: String {
        case settings
        case male
        case female
        case edit = "editAvatar"
        case hanger
        case close
        case back
    }
    
    private(set) var imageType: ImageType = .settings
    
    private let counterContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.sfSeparatorLight.cgColor
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfAccentSecondary
        label.font = Palette.fontBold.withSize(10)
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(counterContainerView)
        counterContainerView.addSubview(counterLabel)
        
        setupConstraints()
    }
    
    convenience init(imageType: ImageType, type: UIButtonType = .system) {
        self.init(type: type)
        
        backgroundColor = .white
        tintColor = .sfAccentSecondary
        
        setImageType(imageType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageType(_ imageType: ImageType) {
        self.imageType = imageType
        
        setImage(UIImage(libraryNamed: imageType.rawValue), for: .normal)
    }
    
    func setCount(_ count: Int) {
        guard count > 0 else { return }
        counterContainerView.isHidden = false
        counterLabel.text = count.description
    }
    
    private func setupConstraints() {
        counterContainerView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(-4.0)
        }
        
        counterLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6.0)
            make.right.equalToSuperview().offset(-6.0)
            make.top.equalToSuperview().offset(4.0)
            make.bottom.equalToSuperview().offset(-4.0)
            make.width.greaterThanOrEqualTo(8)
            make.height.equalTo(12)
        }
    }
    
}
