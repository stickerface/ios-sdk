import UIKit

public protocol StickerFaceDelegate: AnyObject {
    func stickerFace(viewController: UIViewController, didReceive avatar: SFAvatar)
    func stickerFace(didCanceled viewController: UIViewController)
}

public class StickerFace {
    
    public weak var delegate: StickerFaceDelegate?
    
    public static let shared = StickerFace()
    
    public init() {
        StickerFaceFonts.setup()
        EditorHelper.shared.loadEditor()
    }
    
    public func createAvatarController() -> UIViewController {
        let rootViewController = RootNavigationController.shared
        rootViewController.openGenerateAvatar()
        
        return rootViewController
    }
    
    public func editorController(avatar: SFAvatar) -> UIViewController {
        let rootViewController = RootNavigationController.shared
        rootViewController.openEditor(avatar: avatar)
        
        return rootViewController
    }
    
    public func openCreateAvatarController(_ animated: Bool) {
        let viewController = Utils.getRootViewController()

        viewController?.present(createAvatarController(), animated: animated)
    }
    
    public func removeLayer(in subsection: String, from layers: String) -> String {
        return EditorHelper.shared.removeLayer(in: subsection, from: layers)
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

    public func logoutUser() {
        SFDefaults.tonClient = nil
        SFDefaults.wasEdited = false
    }
}
