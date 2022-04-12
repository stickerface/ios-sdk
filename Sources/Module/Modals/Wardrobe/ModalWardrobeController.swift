import UIKit
import IGListKit

protocol ModalWardrobeDelegate: AnyObject {
    
}

class ModalWardrobeController: ModalScrollViewController {

    weak var delegate: ModalWardrobeDelegate?
    
    let mainView = ModalWardrobeView()
    var model: WardrobeSectionModel!
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    override init() {
        super.init()
        
        mainView.subtitleLabel.isHidden = UserSettings.wardrobe.isEmpty
        model = WardrobeSectionModel(layers: UserSettings.wardrobe)
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
        // TODO: did select wardrobe layer
    }
}
