import UIKit

class RootNavigationController: UINavigationController {

    static let shared = RootNavigationController()
    
    override var childForStatusBarStyle: UIViewController? {
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
        let generateAvatar = GenerateAvatarViewController()
        setViewControllers([generateAvatar], animated: false)
    }
    
    func openEditor(avatar: SFAvatar) {
        let editor = StickerFaceViewController(avatar: avatar)
        setViewControllers([editor], animated: false)
    }
}
