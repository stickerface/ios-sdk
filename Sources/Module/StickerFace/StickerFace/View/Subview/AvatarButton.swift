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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
    
}
