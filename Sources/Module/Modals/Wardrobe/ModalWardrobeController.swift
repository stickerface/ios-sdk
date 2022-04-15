import UIKit
import IGListKit

protocol ModalWardrobeDelegate: AnyObject {
    func modalWardrobeController(_ controller: ModalWardrobeController, needLayers forLayer: String) -> String
    func modalWardrobeController(_ controller: ModalWardrobeController, didSave layers: String)
}

class ModalWardrobeController: ModalScrollViewController {

    weak var delegate: ModalWardrobeDelegate?
    
    let mainView = ModalWardrobeView()
    var model: WardrobeSectionModel!
    
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    
    override init() {
        super.init()
        
        let wardrobe = UserSettings.wardrobe
        let currentLayers = UserSettings.layers
        var selectedLayer: String? = nil
        
        for layer in wardrobe {
            selectedLayer = currentLayers?.contains(layer) == true ? layer : nil
        }
        
        mainView.subtitleLabel.isHidden = wardrobe.isEmpty
        model = WardrobeSectionModel(layers: UserSettings.wardrobe)
        model.selectedLayer = selectedLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(mainView)
        
        adapter.collectionView = mainView.collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    private func layout() {
        mainView.pin
            .below(of: hideIndicatorView).marginTop(12.0)
            .left()
            .width(contentWidth)
        
        mainView.layoutIfNeeded()
        
        contentHeight = mainView.containerView.bounds.height
    }
    
}

// MARK: - ListAdapterDataSource
extension ModalWardrobeController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [model]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let controller = WardrobeSectionController()
        controller.delegate = self
        
        return controller
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return ModalWardrobeEmptyView()
    }
}

// MARK: - WardrobeSectionControllerDelegate
extension ModalWardrobeController: WardrobeSectionControllerDelegate {
    func wardrobeSectionController(_ controller: WardrobeSectionController, didSelect layer: String) {
        let modal = ModalNewLayerController(type: .NFT)
        let layers = delegate?.modalWardrobeController(self, needLayers: layer) ?? ""
        modal.updateView(layer: layer, layers: layers, balance: nil, price: nil)
        modal.delegate = self
        
        present(modal, animated: true)
    }
}

// MARK: - WardrobeSectionControllerDelegate
extension ModalWardrobeController: ModalNewLayerDelegate {
    func modalNewLayerController(_ controller: ModalNewLayerController, didBuy layer: String, layerType: LayerType, allLayers: String) { }
    
    func modalNewLayerController(_ controller: ModalNewLayerController, didSave layer: String, allLayers: String) {
        model.selectedLayer = layer
        delegate?.modalWardrobeController(self, didSave: allLayers)
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    
}
