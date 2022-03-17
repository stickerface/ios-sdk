import UIKit
import SnapKit

enum NavBarRightButtonStyle {
    case back
    case close
}

class PassThroughView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden, subview.isUserInteractionEnabled,
               subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        
        return false
    }
    
}

class NavBar: UIViewController {
    
    enum Constants {
        static let height: CGFloat = 48
        static let buttonMargin: CGFloat = 8
    }
    
    public var isClosing = false
    
    var leftButtonStyle: NavBarRightButtonStyle = .back {
        didSet {
            let icon = leftButtonStyle == .back ? "back_28" : "close_28"
            backBtn.setImage(UIImage(libraryNamed: icon)?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    private(set) lazy var contentView: UIView = {
        let contentView = PassThroughView()
        contentView.addSubview(backBtn)
        contentView.addSubview(titleView)
        contentView.addSubview(rightButtonsStackView)

        return contentView
    }()
    
    let backBtn: UIButton = {
        let backBtn = UIButton()
        backBtn.setImage(UIImage(libraryNamed: "back_28")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.contentMode = .scaleAspectFit
        backBtn.tintColor = .sfAccentBrand
        
        return backBtn
    }()
    
    let rightButtonsStackView: UIStackView = {
        let rightButtonsStackView = UIStackView()
        rightButtonsStackView.alignment = .fill
        rightButtonsStackView.axis = .horizontal
        rightButtonsStackView.distribution = .fillEqually
        
        return rightButtonsStackView
    }()

    var rightBtn: NavBarButton? {
        didSet {
            if let btn = rightBtn {
                btn.snp.makeConstraints { make in
                    make.size.equalTo(NavBarButton.Layout.size)
                }
                rightButtonsStackView.addArrangedSubview(btn)
            }
        }
    }
    
    let titleView: UILabel = {
        let titleView = UILabel()
        titleView.textAlignment = .center
        titleView.font = Palette.fontBold.withSize(18)
        
        return titleView
    }()
    
    override public var title: String? {
        didSet {
            titleView.text = title
        }
    }
    
    override func loadView() {
        super.loadView()
        
        let passThroughView = PassThroughView(frame: view.frame)
        passThroughView.layer.zPosition = 10
        
        view = passThroughView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentView)
                
        backBtn.addTarget(self, action: #selector(backBtnDidPress), for: .touchUpInside)
        
        setupConstraints()
    }
    
    public func setLeftButtonStyle(_ style: NavBarRightButtonStyle) {
        leftButtonStyle = style
    }
}

// MARK: - Private methods
fileprivate extension NavBar {
    
    @objc func backBtnDidPress() {
        isClosing = true

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            if leftButtonStyle == .back {
                Utils.getRootNavigationController()?.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupConstraints() {
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(presentingViewController != nil ? 2.0 : Utils.safeArea().top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(Constants.height)
        }
        
        backBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(Constants.buttonMargin)
            make.size.equalTo(Constants.height)
        }
        
        rightButtonsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-Constants.buttonMargin)
        }
        
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
}
