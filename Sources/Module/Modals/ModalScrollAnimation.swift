import UIKit

class ModalScrollAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.2
    let isPresenting: Bool!

    init(presenting: Bool) {
        self.isPresenting = presenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        var modalRaw: ModalScrollViewController?
        var toView: UIView
        if isPresenting {
            modalRaw = transitionContext.viewController(forKey: .to) as? ModalScrollViewController
            toView = transitionContext.view(forKey: .to)!
        } else {
            modalRaw = transitionContext.viewController(forKey: .from) as? ModalScrollViewController
            toView = transitionContext.view(forKey: .from)!
        }
        guard let modal = modalRaw else { return }

        containerView.addSubview(toView)

        modal.locked = true
        if isPresenting {
            modal.blackoutView.alpha = 0
            modal.scrollView.frame.origin.y = modal.contentHeight
        } else {
            modal.scrollView.transform = CGAffineTransform(translationX: 0, y: -modal.scrollView.contentOffset.y)
            modal.scrollView.contentInset.top = 0
            modal.scrollView.scrollToTop(animated: false)
            modal.scrollView.clipsToBounds = false
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            modal.blackoutView.alpha = self.isPresenting ? 1 : 0
            if self.isPresenting {
                modal.scrollView.frame.origin.y = 0
            } else {
                modal.scrollView.transform = CGAffineTransform(translationX: 0, y:  modal.view.frame.height)
            }
        }, completion: { _ in
            modal.locked = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
