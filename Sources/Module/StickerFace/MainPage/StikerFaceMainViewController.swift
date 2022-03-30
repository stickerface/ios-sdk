import UIKit
import IGListKit

class StikerFaceMainViewController: ViewController<StikerFaceMainView> {

    var layers = ""
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adapter.collectionView = mainView.collectionView
        adapter.dataSource = self
    }
    
    func updateLayers(_ layers: String) {
        self.layers = layers
        adapter.reloadData(completion: nil)
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
            return StickerFaceMainStickersSectionController()
            
        default:
            preconditionFailure("Unknown object type")
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

