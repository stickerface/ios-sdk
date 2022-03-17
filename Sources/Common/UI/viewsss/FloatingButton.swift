import UIKit

class FloatingButton: UIControl {
    
    enum Constants {
        static let size: CGFloat = 64
        static let sizeSmall: CGFloat = 32
    }

    enum Size {
        case small
        case normal
    }

    let btnSize: CGFloat

    lazy var imageView: UIImageView = {
        let imageSize: CGFloat = 28
        let imageView = UIImageView(frame: CGRect(x: (btnSize - imageSize) / 2, y: (btnSize - imageSize) / 2, width: imageSize, height: imageSize))
        imageView.image = UIImage(libraryNamed: "add_28")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        return imageView
    }()

    init(_ size: Size? = .normal) {
        self.btnSize = size == .normal ? Constants.size : Constants.sizeSmall
        super.init(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        
        layer.cornerRadius = frame.width / 2
        backgroundColor = .sfAccentBrand
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            let scale: CGFloat = isHighlighted ? 0.9 : 1
            let color = isHighlighted ? UIColor.sfAccentBrand : UIColor.sfAccentBrand
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.backgroundColor = color
            })
        }
    }
}
