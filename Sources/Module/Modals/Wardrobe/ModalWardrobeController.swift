import UIKit

class ModalWardrobeController: ModalScrollViewController {

    let wardrobeView = ModalWardrobeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(wardrobeView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    private func layout() {
        wardrobeView.pin
            .below(of: hideIndicatorView).marginTop(12.0)
            .left()
            .width(contentWidth)
        
        wardrobeView.layoutIfNeeded()
        
        contentHeight = wardrobeView.containerView.bounds.height
    }
    
}
