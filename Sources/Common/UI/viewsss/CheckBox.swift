import UIKit

class CheckBox: UIButton {

    init() {
        super.init(frame: .zero)
        setImage(UIImage(libraryNamed: "uncheckmark"), for: .normal)
        setImage(UIImage(libraryNamed: "checkmark"), for: .selected)
        setImage(UIImage(libraryNamed: "grayCheckmark"), for: .highlighted)
        setBackgroundImage(nil, for: [.normal, .selected])
        titleLabel?.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
