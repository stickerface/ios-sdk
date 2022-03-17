import UIKit

class NavBarButton: UIButton {

    enum Layout {
        static let margin: CGFloat = 8
        static let size: CGFloat = 48
        static let iconSize: CGFloat = 28
    }

    override var buttonType: UIButton.ButtonType {
        return .system
    }

    func setup(icon: UIImage?) {
        frame.size = CGSize(side: Layout.size)
        setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        contentMode = .scaleAspectFit
        let inset = (Layout.size - Layout.iconSize) / 2
        imageEdgeInsets = UIEdgeInsets.init(top: inset, left: inset, bottom: inset, right: inset)
        tintColor = .sfAccentBrand
    }
}
