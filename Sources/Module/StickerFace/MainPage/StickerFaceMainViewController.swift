import UIKit
import IGListKit

protocol StickerFaceMainViewControllerDelegate: AnyObject {
    func stickerFaceMainViewController(didSelect sticker: UIImage?)
    func stickerFaceMainViewController(needAllLayers withLayers: [(layer: String, color: String?)]) -> String
}

class StickerFaceMainViewController: ViewController<StickerFaceMainView> {

    var layers = ""
    
    weak var delegate: StickerFaceMainViewControllerDelegate?
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        
        adapter.collectionView = mainView.collectionView
        adapter.dataSource = self
    }
    
    func updateLayers(_ layers: String) {
        self.layers = layers
        adapter.reloadData()
    }
    
    @objc private func exportButtonTapped() {
        let viewController = ModalExportController()
        viewController.layers = layers
        viewController.view.layoutIfNeeded()
        
        present(viewController, animated: true)
    }
    
}

// MARK: - ListAdapterDataSource
extension StickerFaceMainViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [
            StickerFaceMainStore(),
            StickerFaceMainMint(),
            StickerFaceMainSticker(layers: layers)
        ]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is StickerFaceMainStore:
            let section = StickerFaceMainStoreSectionController()
            section.delegate = self
            
            return section
            
        case is StickerFaceMainMint:
            return StickerFaceMainMintSectionController()
            
        case is StickerFaceMainSticker:
            let section = StickerFaceMainStickersSectionController()
            section.delegate = self
            
            return section
            
        default:
            preconditionFailure("Unknown object type")
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

// MARK: - StickersSectionControllerDelegate
extension StickerFaceMainViewController: StickersSectionControllerDelegate {
    func stickersSectionController(didSelect sticker: UIImage?) {
        delegate?.stickerFaceMainViewController(didSelect: sticker)
    }
}

// MARK: - StickerFaceMainStoreSectionDelegate
extension StickerFaceMainViewController: StickerFaceMainStoreSectionDelegate {
    func stickerFaceMainStoreSection(needAllLayers withLayers: [(layer: String, color: String?)]) -> String {
        return delegate?.stickerFaceMainViewController(needAllLayers: withLayers) ?? ""
    }
}
