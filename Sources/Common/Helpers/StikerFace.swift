import UIKit

public class StikerFace {

    public static let shared = StikerFace()

    public init() {
        StikerFaceFonts.setup()
    }
    
    public func openStikerFace() {
        let viewController = Utils.getRootViewController()
        let onboardingVC = OnboardingViewController()
        onboardingVC.modalPresentationStyle = .fullScreen
        
        viewController?.present(onboardingVC, animated: true)
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
