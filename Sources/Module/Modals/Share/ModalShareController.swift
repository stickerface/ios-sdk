import UIKit

class ModalShareController: ModalScrollViewController {
    
    let shareView = ModalShareView()
    
    init(shareImage: UIImage?) {
        super.init()
        
        shareView.imageView.image = shareImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(shareView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    private func layout() {
        shareView.pin.below(of: hideIndicatorView).marginTop(12.0).left().width(contentWidth)

        shareView.layoutIfNeeded()
        
        contentHeight = shareView.bounds.height
    }

}
