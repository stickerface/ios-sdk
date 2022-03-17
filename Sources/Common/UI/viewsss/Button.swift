import UIKit

class Button: UIControl {

    enum Layout {
        static let paddingHorizontal: CGFloat = 35.5
        static let height: CGFloat = 44
        static let titleHeight: CGFloat = 24
    }

    var title: String = "" {
        didSet {
            titleLabel.text = title
            update()
        }
    }

    lazy var titleLabel: UILabel  = {
        let titleLabel = UILabel()
        titleLabel.font = Palette.Fonts.bold.withSize(18)
        titleLabel.textColor = .white
        return titleLabel
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .sfAccentBrand
        layer.cornerRadius = Layout.height / 2

        addSubview(titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
                origin: CGPoint(x: Layout.paddingHorizontal, y: (Layout.height - Layout.titleHeight) / 2),
                size: CGSize(
                        width: titleLabel.frame.width,
                        height: Layout.titleHeight
                )
        )

        frame.size = CGSize(width: titleLabel.frame.width + Layout.paddingHorizontal * 2, height: Layout.height)
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.backgroundColor = self.isHighlighted ? .sfAccentBrand : .sfAccentBrand
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }, completion: nil)
        }
    }
}

class ButtonStretch: UIControl {
    lazy var titleLabel: UILabel  = {
        let titleLabel = UILabel()
        titleLabel.font = Palette.Fonts.bold.withSize(18)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    var title: String = "" {
        didSet {
            titleLabel.text = title
            titleLabel.sizeToFit()
        }
    }

    init(width: CGFloat) {
        super.init(frame: CGRect(
                origin: .zero,
                size: CGSize(width: width, height: Button.Layout.height)
        ))

        backgroundColor = .sfAccentBrand
        layer.cornerRadius = Button.Layout.height / 2

        addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.backgroundColor = self.isHighlighted ? .sfAccentBrand : .sfAccentBrand
            }, completion: nil)
        }
    }
}
