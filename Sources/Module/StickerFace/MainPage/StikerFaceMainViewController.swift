import UIKit
import IGListKit

protocol StikerFaceMainViewControllerDelegate: AnyObject {
    func stikerFaceMainViewController(didSelect sticker: UIImage?)
}

class StikerFaceMainViewController: ViewController<StikerFaceMainView> {

    var layers = ""
    
    weak var delegate: StikerFaceMainViewControllerDelegate?
    
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
        adapter.reloadData(completion: nil)
    }
    
    @objc private func exportButtonTapped() {
        let viewController = ModalExportController()
        viewController.layers = layers
        viewController.view.layoutIfNeeded()
        
        present(viewController, animated: true)
    }
    
}

// MARK: - ListAdapterDataSource
extension StikerFaceMainViewController: ListAdapterDataSource {
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
            return StickerFaceMainStoreSectionController()
            
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

extension StikerFaceMainViewController: StickersSectionControllerDelegate {
    func stickersSectionController(didSelect sticker: UIImage?) {
        delegate?.stikerFaceMainViewController(didSelect: sticker)
    }
}

