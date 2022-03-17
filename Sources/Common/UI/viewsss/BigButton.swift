import UIKit

protocol BigButtonDelegate {
    
    func bigButtonDidPress(_ button: BigButton)
    
}

enum BigButtonStyle {
    case normal
    case light
}

class BigButton: UIButton {
    
    var delegate: BigButtonDelegate?
    
    var style: BigButtonStyle = .normal {
        didSet {
            switch style {
            case .light:
                tintColor = .sfAccentBrand
                titleLabel?.textColor = .sfAccentBrand
                backgroundColor = .white
                break
            default:
                print("unknown style")
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 22
        backgroundColor = .sfAccentBrand
        tintColor = .white
        
        titleLabel?.font = Palette.fontBold.withSize(18)

        contentEdgeInsets = UIEdgeInsets(top: 10, left: 32.5, bottom: 10, right: 32.5)
        
        //addTarget(self, action: #selector(didDown), for: .touchDown)
        //addTarget(self, action: #selector(didUp), for: .touchUpOutside)
        addTarget(self, action: #selector(didPress), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        didDown()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        didUp()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        didUp()
    }
}

extension BigButton {
    
    @objc func didPress() {
        delegate?.bigButtonDidPress(self)
        didUp()
    }
    
    @objc func didDown() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    @objc func didUp() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
}
