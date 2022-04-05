import UIKit

class ModalBuyController: ModalScrollViewController {

    enum BuyType {
        case nft
        case background
    }
    
    let buyView: ModalBuyView
    let type: BuyType
    
    init(type: BuyType) {
        self.type = type
        buyView = ModalBuyView(type: type)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(buyView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    private func layout() {
        buyView.pin
            .below(of: hideIndicatorView).marginTop(12.0)
            .left()
            .width(contentWidth)
        
        buyView.layoutIfNeeded()
        
        contentHeight = buyView.containerView.bounds.height
    }

}
