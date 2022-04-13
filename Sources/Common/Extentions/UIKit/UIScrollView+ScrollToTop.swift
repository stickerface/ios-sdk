import UIKit

private extension UIScrollView {
    @discardableResult
    @NSManaged func _scrollToTopIfPossible(_ animated: ObjCBool) -> ObjCBool
}

public extension UIScrollView {
    
    @objc func scrollToTopIfPossible(animated: Bool) {
        if responds(to: #selector(UIScrollView._scrollToTopIfPossible)) {
            _scrollToTopIfPossible(ObjCBool(animated))
        } else {
            scrollToTop(animated: animated)
        }
    }
    
    func scrollToTop(animated: Bool) {
        self.setContentOffset(CGPoint(x: contentOffset.x, y: -contentInset.top), animated: animated)
    }
    
}
