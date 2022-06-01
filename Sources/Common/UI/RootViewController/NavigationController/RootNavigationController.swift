import UIKit

class RootNavigationController: UINavigationController {

    static let shared = RootNavigationController()
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        
        interactivePopGestureRecognizer?.isEnabled = true
        navigationBar.isHidden = true
        setNavigationBarHidden(true, animated: false)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func openGenerateAvatar() {
        let rootVC = GenerateAvatarViewController()
        setViewControllers([rootVC], animated: false)
    }

    func updateRootController() {
        var rootVC: UIViewController = OnboardingViewController()
        
        if UserSettings.isOnboardingShown {
            if let layers = UserSettings.layers {
                rootVC = StickerFaceViewController(type: .editor, layers: layers)
            } else {
                rootVC = GenerateAvatarViewController()
            }
        }

        setViewControllers([rootVC], animated: false)
    }
}
