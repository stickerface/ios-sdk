import UIKit

public protocol StickerFaceDelegate: AnyObject {
    func stickerFace(viewController: UIViewController, didReceive avatar: UIImage)
}

public class StickerFace {
    
    public weak var delegate: StickerFaceDelegate?
    
    public static let shared = StickerFace()
    
    public init() {
        StickerFaceFonts.setup()
    }
    
    public func openStickerFace() {
        let viewController = Utils.getRootViewController()

        viewController?.present(getRootNavigationController(), animated: true)
    }
    
    public func getRootNavigationController() -> UINavigationController {
        let navigationController = RootNavigationController.shared
        
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
            TonNetwork.loginClient(url: incomingURL)
        }
    }
    
    public func receiveAvatar(_ avatar: UIImage) {
        delegate?.stickerFace(viewController: RootNavigationController.shared, didReceive: avatar)
    }
    
    public func logoutUser() {
        UserSettings.layers = nil
        UserSettings.tonClient = nil
        
        RootNavigationController.shared.updateRootController()
    }

}
