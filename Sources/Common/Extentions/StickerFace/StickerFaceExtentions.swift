import UIKit

extension StickerFace {
    
    func getRootNavigationController() -> UINavigationController {
        let navigationController = RootNavigationController.shared
        
        return navigationController
    }
    
    func receiveAvatar(_ avatar: SFAvatar) {
        RootNavigationController.shared.dismiss(animated: true)
        delegate?.stickerFace(viewController: RootNavigationController.shared, didReceive: avatar)
    }
    
}
