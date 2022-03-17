import UIKit
import IGListKit

protocol StickerFaceEditorPageDelegate: AnyObject {
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, emptyView forListAdapter: ListAdapter) -> UIView?
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, didSelect layer: String, section: Int)
}

class StickerFaceEditorPageController: ViewController<StickerFaceEditorPageView> {

    weak var delegate: StickerFaceEditorPageDelegate?
    
    var sectionModel: EditorSubsectionSectionModel
    var index = 0
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    init(sectionModel: EditorSubsectionSectionModel) {
        self.sectionModel = sectionModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter.collectionView = mainView.collectionView
        adapter.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        adapter.reloadData(completion: nil)
    }

}

// MARK: - ListAdapterDataSource
extension StickerFaceEditorPageController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [sectionModel]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let stickerFaceEditorSectionController = StickerFaceEditorSectionController()
        stickerFaceEditorSectionController.delegate = self
        
        return stickerFaceEditorSectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return delegate?.stickerFaceEditorPageController(self, emptyView: listAdapter)
    }
}

// MARK: - StickerFaceEditorSectionControllerDelegate
extension StickerFaceEditorPageController: StickerFaceEditorSectionControllerDelegate {
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, didSelect layer: String, section: Int) {
        delegate?.stickerFaceEditorPageController(self, didSelect: layer, section: index)
    }
    
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, willDisplay header: String, in section: Int) { }
}
