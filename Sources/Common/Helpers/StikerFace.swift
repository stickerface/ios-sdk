import UIKit

public class StikerFace {

    public static let shared = StikerFace()

    public init() {
        StikerFaceFonts.setup()
    }
    
    public func openStikerFace() {
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
