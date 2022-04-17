import UIKit

protocol ModalNewLayerDelegate: AnyObject {
    func modalNewLayerController(_ controller: ModalNewLayerController, didBuy layer: String, layerType: LayerType, allLayers: String)
    func modalNewLayerController(_ controller: ModalNewLayerController, didSave layer: String, allLayers: String)
}

class ModalNewLayerController: ModalScrollViewController {
    
    weak var delegate: ModalNewLayerDelegate?
    
    let mainView = ModalNewLayerView()
    let type: LayerType
    
    var selectedLayer: String = ""
    var allLayers: String = ""
    
    init(type: LayerType) {
        self.type = type
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(mainView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    // MARK: - Public methods
    
    // TODO: - как мне считать в долларах?
    func updateView(layer: String, layers: String, balance: Double?, price: Int?) {
        selectedLayer = layer
        allLayers = layers
        
        ImageLoader.setAvatar(with: layers, for: mainView.imageView,
                              side: 197, cornerRadius: 197/2)
        
        if let price = price {
            if price == 0 {
                mainView.priceLabel.text = "commonFree".libraryLocalized
                mainView.priceSubtitleLabel.isHidden = true
            } else {
                mainView.priceLabel.text = "\(price) TON"
                mainView.priceSubtitleLabel.isHidden = false
            }
            
            if let balance = balance {
                mainView.buyButton.setImage(nil, for: .normal)
                
                if balance >= Double(price) {
                    mainView.titleLabel.text = "newLayerPurchase".libraryLocalized
                    mainView.subtitleLabel.text = type == .background ?
                    "newLayerBackPurchase".libraryLocalized :
                    "newLayerNFTPurchase".libraryLocalized
                    
                    mainView.buyButton.setTitle("newLayerBuyNFT".libraryLocalized, for: .normal)
                    mainView.buyButton.addTarget(self, action: #selector(buyLayer), for: .touchUpInside)
                } else {
                    let addCount = Double(price) - balance
                    mainView.titleLabel.text = "newLayerInsufficientFunds".libraryLocalized
                    mainView.subtitleLabel.text = "newLayerAddMinimum".libraryLocalized(addCount)
                    mainView.buyButton.setTitle("newLayerReplenish".libraryLocalized, for: .normal)
                }
                
            } else {
                mainView.titleLabel.text = "newLayerConnectWallet".libraryLocalized
                mainView.subtitleLabel.text = type == .background ?
                "newLyaerBackConnectTonkeeper".libraryLocalized :
                "newLyaerNFTConnectTonkeeper".libraryLocalized
                mainView.buyButton.setTitle("connectWalletConnectTitle".libraryLocalized, for: .normal)
                mainView.buyButton.setImage(UIImage(libraryNamed: "tonkeeper_1"), for: .normal)
            }
        } else {
            mainView.priceLabel.isHidden = true
            mainView.priceSubtitleLabel.isHidden = true
            mainView.titleLabel.text = "newLayerFitting".libraryLocalized
            mainView.subtitleLabel.text = "newLayerLookGood".libraryLocalized
            mainView.buyButton.setTitle("newLayerDress".libraryLocalized, for: .normal)
            mainView.buyButton.setImage(nil, for: .normal)
            
            mainView.buyButton.addTarget(self, action: #selector(saveLayer), for: .touchUpInside)
        }
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Private actions
    
    @objc private func buyLayer() {
        delegate?.modalNewLayerController(self, didBuy: selectedLayer, layerType: type, allLayers: allLayers)
    }
    
    @objc private func saveLayer() {
        delegate?.modalNewLayerController(self, didSave: selectedLayer, allLayers: allLayers)
    }
    
    // MARK: - Private methods
    
    private func layout() {
        mainView.pin
            .below(of: hideIndicatorView).marginTop(12.0)
            .left()
            .width(contentWidth)
        
        mainView.layoutIfNeeded()
        
        contentHeight = mainView.containerView.bounds.height
    }

}
