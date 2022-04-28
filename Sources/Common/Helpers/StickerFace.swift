import UIKit

public class StickerFace {

    public static let shared = StickerFace()

    public init() {
        StickerFaceFonts.setup()
    }
    
    public func openStickerFace() {
        let rootVC = UserSettings.isOnboardingShown ? GenerateAvatarViewController() : OnboardingViewController()
        UserSettings.isOnboardingShown = true
        let viewController = Utils.getRootViewController()
        let navigationController = RootNavigationController()
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([rootVC], animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.barStyle = .black
        
        viewController?.present(navigationController, animated: true)
    }
    
    public func getRootNavigationController() -> UINavigationController {
        let rootVC = UserSettings.isOnboardingShown ? GenerateAvatarViewController() : OnboardingViewController()
        UserSettings.isOnboardingShown = true
        let navigationController = UINavigationController()
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([rootVC], animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        
        return navigationController
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
