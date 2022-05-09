import UIKit

public class StickerFace {

    public static let shared = StickerFace()

    public init() {
        StickerFaceFonts.setup()
    }
    
    public func openStickerFace() {
        let viewController = Utils.getRootViewController()
        
        viewController?.present(getRootNavigationController(), animated: true)
    }
    
    public func getRootNavigationController() -> UINavigationController {
        let rootVC = UserSettings.isOnboardingShown ? GenerateAvatarViewController() : OnboardingViewController()
        UserSettings.isOnboardingShown = false
        let navigationController = RootNavigationController()
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.navigationBar.isHidden = true
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
    
    public func handle(userActivity: NSUserActivity) {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
        else { return }
        
        if components.path == "/api/tonkeeper/login" {
            TonNetwork().loginClient(url: incomingURL)
        }
    }

}
