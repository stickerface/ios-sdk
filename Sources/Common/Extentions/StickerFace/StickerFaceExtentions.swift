import UIKit

extension StickerFace {
    
    func getRootNavigationController() -> UINavigationController {
        let navigationController = RootNavigationController.shared
        
        return navigationController
    }
    
    func receiveAvatar(_ avatar: SFAvatar) {
        delegate?.stickerFace(viewController: RootNavigationController.shared, didReceive: avatar)
    }
    
    func cancelChange() {
        StickerLoader.shared.clearRenderQueue()
        delegate?.stickerFace(didCanceled: RootNavigationController.shared)
    }
}
