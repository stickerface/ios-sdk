import UIKit
import IGListKit

class StikerFaceMainViewController: ViewController<StikerFaceMainView> {

    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adapter.collectionView = mainView.collectionView
        adapter.dataSource = self
    }
    
}

// MARK: - ListAdapterDataSource
extension StikerFaceMainViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [StickerFaceMainStore()]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is StickerFaceMainStore:
            return StickerFaceMainStoreSectionController()
            
        default:
            preconditionFailure("Unknown object type")
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

