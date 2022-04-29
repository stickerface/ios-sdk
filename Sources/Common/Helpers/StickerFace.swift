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
        let layers = UserSettings.layers ?? ""
        
        print("===", layers)
        
        let viewController = layers == "" ? GenerateAvatarViewController() : StickerFaceViewController(type: .main, layers: layers)
        let rootVC = UserSettings.isOnboardingShown ? viewController : OnboardingViewController()
        UserSettings.isOnboardingShown = true

        let navigationController = RootNavigationController()
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
