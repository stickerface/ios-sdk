import UIKit

public class StickerFace {

    public static let shared = StickerFace()

    public init() {
        StickerFaceFonts.setup()
    }
    
    public func openStickerFace() {
        let viewController = Utils.getRootViewController()
        let navigationController = UINavigationController()
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.navigationBar.isHidden = true
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([OnboardingViewController()], animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        
        viewController?.present(navigationController, animated: true)
    }
    
    public func open(controller: UIViewController) {
        guard let nav = Utils.getRootNavigationController() else { return }
        if nav.presentedViewController == nil {
            nav.pushViewController(controller, animated: true)
        } else {
            nav.present(controller, animated: true)
        }
    }

}
