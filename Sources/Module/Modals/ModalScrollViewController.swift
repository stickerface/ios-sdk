import UIKit

class ModalScrollViewController: UIViewController {

    var skipBottomInset: Bool {
        get {
            return false
        }
    }

    open var contentHeight: CGFloat = 100 {
        didSet {
            if oldValue != contentHeight {
                updateContentSize()
            }
        }
    }

    open var contentWidth: CGFloat {
        get {
            return scrollView.frame.width
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var skipInsetUpdate = false
    var locked = false
    var shown = false

    // TODO: Убрать лейзи
    lazy var hideHelper: UIView = {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(hideHelperDidPress))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()

    // TODO: Убрать лейзи
    lazy var blackoutView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.frame = self.view.frame
        
        return view
    }()

    // TODO: Убрать лейзи
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: view.frame)
        view.delegate = self
        view.autoresizingMask = .flexibleHeight
        view.alwaysBounceVertical = true
        view.contentInsetAdjustmentBehavior = .never
        view.contentInset.bottom = 0
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        
        return view
    }()

    var hideIndicatorView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 28.0, height: 4)))
        view.layer.cornerRadius = 2
        view.backgroundColor = UIColor.white
        
        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        if #available(iOS 13.0, *) {
            isModalInPresentation = false
        }
        transitioningDelegate = self
        modalPresentationCapturesStatusBarAppearance = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(blackoutView)
        view.addSubview(scrollView)
        scrollView.backgroundColor = .clear

        scrollView.addSubview(hideIndicatorView)
        scrollView.addSubview(hideHelper)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateContentSize()

        hideIndicatorView.frame.origin = CGPoint(
                x: (contentWidth - hideIndicatorView.frame.width) / 2,
                y: -12 - hideIndicatorView.frame.height
        )

        hideHelper.frame = CGRect(
                origin: CGPoint(x: 0, y: -scrollView.contentInset.top),
                size: CGSize(width: scrollView.frame.width, height: scrollView.contentInset.top)
        )
    }

    func updateContentSize(forceUpdateInset: Bool = false) {
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)

        if !skipInsetUpdate || forceUpdateInset {
            updateInset()
        }
    }

    func updateInset() {
        scrollView.contentInset.top = max(50, view.bounds.height - contentHeight)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        skipInsetUpdate = true
    }

    func hide(completion: (() -> Swift.Void)? = nil) {
        locked = true
        view.isUserInteractionEnabled = false
        dismiss(animated: true, completion: completion)
    }
}

fileprivate extension ModalScrollViewController {
    @objc func hideHelperDidPress() {
        hide()
    }
}


extension ModalScrollViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if locked {
            return
        }

        if scrollView.contentOffset.y < -Utils.safeArea().top {
            let offset = min(0, scrollView.contentOffset.y + Utils.safeArea().top + scrollView.contentInset.top)
            let alpha = 1 - max(0, -(offset / (scrollView.contentSize.height)))
            blackoutView.alpha = alpha
        } else {
            blackoutView.alpha = 1
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if locked {
            return
        }
        if scrollView.contentOffset.y + scrollView.contentInset.top <= -70 {
            hide()
        }
    }
}

// - MARK: UIViewControllerTransitioningDelegate

extension ModalScrollViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalScrollAnimation(presenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalScrollAnimation(presenting: false)
    }
}
