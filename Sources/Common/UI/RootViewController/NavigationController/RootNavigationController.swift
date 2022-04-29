import UIKit

class RootNavigationController: UINavigationController {

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

}
