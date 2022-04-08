import UIKit
import IGListKit

enum LayerType {
    case layers
    case background
    case NFT
}

protocol StickerFaceEditorViewControllerDelegate: AnyObject {
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didUpdate layers: String)
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSelectPaid layer: String, layers withLayer: String, with price: Int, layerType: LayerType)
    func stickerFaceEditorViewControllerShouldContinue(_ controller: StickerFaceEditorViewController)
}

protocol StikerFaceEditorDelegate: AnyObject {
    func updateLayers(_ layers: String)
    func layersWithoutBackground(_ layers: String) -> (background: String, layers: String)
}

class StickerFaceEditorViewController: ViewController<StickerFaceEditorView> {
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    weak var delegate: StickerFaceEditorViewControllerDelegate?
    
    var layers: String = ""
    
    private var loadingState = LoadingState.loading
    private let provider = StickerFaceEditorProvider()
    private var prices: [String: Int] = [:]
    private var headers: [EditorHeaderSectionModel] = []
    private var objects: [EditorSubsectionSectionModel] = []
    private var viewControllers: [UIViewController]? = []
    //    private var productInput: ProductInput?
//    private var newPaidLayers: String?
    
    private lazy var headerAdapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        headerAdapter.collectionView = mainView.headerCollectionView
        headerAdapter.dataSource = self
        
        addChildViewController(mainView.pageViewController)
        
        mainView.pageViewController.didMove(toParentViewController: self)
        mainView.pageViewController.dataSource = self
        mainView.pageViewController.delegate = self
        
        loadEditor()
    }
    
    // MARK: Public mehtods
    
    func shouldHideSaveButton(_ isHidden: Bool) {
        mainView.saveButton.isHidden = isHidden
    }
    
    // MARK: Private actions
    
    @objc private func saveButtonTapped() {
        delegate?.stickerFaceEditorViewControllerShouldContinue(self)
        mainView.saveButton.isHidden = true
    }
    
    @objc private func changeSelectedTab(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard let selectedIndex = headers.firstIndex(where: { $0.isSelected }) else {
            return
        }
        
        var newIndex = selectedIndex
        if gestureRecognizer.direction == .left, selectedIndex + 1 < viewControllers?.count ?? 0 {
            newIndex = selectedIndex + 1
        } else if gestureRecognizer.direction == .right, selectedIndex - 1 >= 0 {
            newIndex = selectedIndex - 1
        }
        
        if let viewController = mainView.pageViewController.viewControllers?.first as? StickerFaceEditorPageController {
            guard
                let viewControllers = viewControllers,
                viewControllers.count > newIndex,
                let vc = viewControllers[newIndex] as? StickerFaceEditorPageController
            else { return }
            
            if newIndex > viewController.index {
                mainView.pageViewController.setViewControllers([vc], direction: .forward, animated: true)
            } else if newIndex < viewController.index {
                mainView.pageViewController.setViewControllers([vc], direction: .reverse, animated: true)
            }
            
            headers.forEach { $0.isSelected = $0.title == vc.sectionModel.editorSubsection.name }
            headerAdapter.reloadData(completion: nil)
            
            mainView.headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: vc.index), at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: Private methods
    
    private func loadEditor() {
        provider.loadEditor { [weak self] result in
            switch result {
            case .success(let editor):
                self?.headers = editor.sections.flatMap({ $0.subsections }).map({ EditorHeaderSectionModel(title: $0.name) })
                self?.headers.first?.isSelected = true
                self?.headerAdapter.performUpdates(animated: true)
                
                self?.prices = editor.prices
                
                #warning("hardcode")
                self?.prices["271"] = 2
                
                self?.objects = editor.sections.flatMap({ $0.subsections }).map({ EditorSubsectionSectionModel(editorSubsection: $0, prices: self!.prices) })
                self?.viewControllers = self?.objects.enumerated().map { index, object in
                    let controller = StickerFaceEditorPageController(sectionModel: object)
                    controller.delegate = self
                    controller.index = index
                    
                    return controller
                }
                self?.updateSelectedLayers()
                self?.loadingState = .loaded
                
                if let viewController = self?.viewControllers?[0] {
                    self?.mainView.pageViewController.setViewControllers([viewController], direction: .reverse, animated: true)
                }
                
                self?.updateUserProducts()
                
            case .failure(let error):
                //                if let error = error as? ImModelError {
                //                    self?.mainView.loaderView.showError(error.message())
                //                }
                self?.mainView.loaderView.showError(error.localizedDescription)
                self?.loadingState = .failed
            }
        }
    }
    
    private func updateUserProducts() {
        //        provider.getUserProducts { [weak self] result in
        //            switch result {
        //            case .success(let productIds):
        //                self?.updatePrices(productIds)
        //
        //            case .failure(let error):
        //                if let error = error as? ImModelError {
        //                    self?.mainView.loaderView.showError(error.message())
        //                }
        //            }
        //        }
    }
    
    private func updatePrices(_ layers: [String]) {
        layers.forEach { prices.removeValue(forKey: $0) }
        objects.enumerated().forEach { index, object in
            object.prices = prices
            
            if let viewController = viewControllers?[index] as? StickerFaceEditorPageController {
                viewController.sectionModel = object
                viewController.adapter.reloadData(completion: nil)
            }
        }
    }
    
    private func replaceCurrentLayer(with replacementLayer: String, section: Int) -> String {
        var layers = layers
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        var layersArray = layers.components(separatedBy: ";")
        
        if let editorLayers = objects[section].editorSubsection.layers,
           editorLayers.contains(replacementLayer) {
            editorLayers.forEach { editorLayer in
                if let index = layersArray.firstIndex(where: { $0 == editorLayer }) {
                    layersArray.remove(at: index)
                }
            }
        } else if let colorLayers = objects[section].editorSubsection.colors?.compactMap({ String($0.id) }),
                  colorLayers.contains(replacementLayer) {
            colorLayers.forEach { colorLayer in
                if let index = layersArray.firstIndex(where: { $0 == colorLayer }) {
                    layersArray.remove(at: index)
                }
            }
        }
        
        layers = layersArray.joined(separator: ";") + ";\(replacementLayer);"
        
        return layers
    }
    
    private func updateSelectedLayers() {
        var layers = layers
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        let layersArray = layers.components(separatedBy: ";")
        
        objects.forEach { object in
            object.selectedColor = nil
            object.selectedLayer = nil
        }
        
        objects.enumerated().forEach { index, object in
            if let editorLayers = object.editorSubsection.layers,
               let layer = editorLayers.first(where: { layersArray.contains($0) }), layer != "0" {
                object.selectedLayer = layer
            }
            
            if let colorLayers = object.editorSubsection.colors?.compactMap({ String($0.id) }),
               let colorId = layersArray.first(where: { colorLayers.contains($0) }) {
                object.selectedColor = colorId
            }
            
            if let viewController = viewControllers?[index] as? StickerFaceEditorPageController {
                viewController.sectionModel = object
                viewController.adapter.reloadData(completion: nil)
            }
        }
    }
    
    private func showConfirmBuyingLayers(price: Int, layers: String) {
        //        let modal = ModalConfirmationController(type: .buyProduct(price: price, layers: layers))
        //
        //        let actionBuyLayers = ProfileTableViewCell(icon: UIImage(libraryNamed: "check_48"), label: "modalChoosePurchasesAgree".libraryLocalized)
        //        actionBuyLayers.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyLayers)))
        //
        //        let actionClose = ProfileTableViewCell(icon: UIImage(libraryNamed: "close_28"), label: "modalChoosePurchasesCancel".libraryLocalized)
        //        actionClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeConfirmBuyingLayers)))
        //
        //        modal.actionsStackView.addArrangedSubview(actionBuyLayers)
        //        modal.actionsStackView.addArrangedSubview(actionClose)
        //
        //        modal.actionsStackView.arrangedSubviews.enumerated().forEach { view in
        //            if view.offset != modal.actionsStackView.arrangedSubviews.count - 1 {
        //                (view.element as? ProfileTableViewCell)?.separator.isHidden = false
        //            }
        //        }
        //
        //        present(modal, animated: true)
    }
    
    private func showConfirmNotEnoughCoins() {
        //        let modal = ModalConfirmationController(type: .notEnoughCoins)
        //
        //        let actionBuyLayers = ProfileTableViewCell(icon: UIImage(libraryNamed: "check_48"), label: "modalChooseBuyCoinsAgree".libraryLocalized)
        //        actionBuyLayers.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCoinsShop)))
        //
        //        let actionClose = ProfileTableViewCell(icon: UIImage(libraryNamed: "close_28"), label: "modalChoosePurchasesCancel".libraryLocalized)
        //        actionClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        //
        //        modal.actionsStackView.addArrangedSubview(actionBuyLayers)
        //        modal.actionsStackView.addArrangedSubview(actionClose)
        //
        //        modal.actionsStackView.arrangedSubviews.enumerated().forEach { view in
        //            if view.offset != modal.actionsStackView.arrangedSubviews.count - 1 {
        //                (view.element as? ProfileTableViewCell)?.separator.isHidden = false
        //            }
        //        }
        //
        //        present(modal, animated: true)
    }
    
    @objc private func closeConfirmBuyingLayers() {
        //        Analytics.shared.register(event: SettingsAnalyticsEvent.stickerFaceBuy(value: false))
    }
    
}

// MARK: - ListAdapterDataSource
extension StickerFaceEditorViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return headers
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let editorHeaderSectionController = EditorHeaderSectionController()
        editorHeaderSectionController.delegate = self
        
        return editorHeaderSectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

// MARK: - EditorHeaderSectionControllerDelegate
extension StickerFaceEditorViewController: EditorHeaderSectionControllerDelegate {
    
    func editorHeaderSectionController(_ controller: EditorHeaderSectionController, didSelect header: String, in section: Int) {
        headers.enumerated().forEach { $0.element.isSelected = $0.element.title == header }
        headerAdapter.reloadData(completion: nil)
        
        mainView.headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: section), at: .centeredHorizontally, animated: true)
        
        if let viewController = mainView.pageViewController.viewControllers?.first as? StickerFaceEditorPageController {
            if section > viewController.index {
                guard let vc = viewControllers?[section] else { return }
                mainView.pageViewController.setViewControllers([vc], direction: .forward, animated: true)
            } else if section < viewController.index {
                guard let vc = viewControllers?[section] else { return }
                mainView.pageViewController.setViewControllers([vc], direction: .reverse, animated: true)
            }
        }
    }
    
}

// MARK: - StickerFaceEditorPageDelegate
extension StickerFaceEditorViewController: StickerFaceEditorPageDelegate {
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, emptyView forListAdapter: ListAdapter) -> UIView? {
        switch loadingState {
        case .loading:
            let view = LoadingView()
            view.play()
            
            return view
        case .loaded:
            let emptyView = PlaceholderView(userId: 0)
            emptyView.stickerId = .crying
            emptyView.caption = "commonNothingWasFound".libraryLocalized
            emptyView.buttonText = String()
            
            //            emptyView.buttonOnClick = {
            //                Utils.getRootNavigationController()?.present(ModalInvite(), animated: true)
            //            }
            
            return HolderView(view: emptyView)
        case .failed:
            let errorView = PlaceholderView(userId: 9)
            errorView.stickerId = .sticker21
            errorView.caption = "commonLoadingError".libraryLocalized
            errorView.buttonText = "commonRetry".libraryLocalized
            
            errorView.buttonOnClick = { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.loadEditor()
            }
            
            return HolderView(view: errorView)
        }
    }
    
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, didSelect layer: String, section: Int) {
        if let price = prices["\(layer)"] {
            let newPaidLayers = replaceCurrentLayer(with: layer, section: section)
            let type: LayerType = objects[section].editorSubsection.name == "background" ? .background : .NFT
            
            delegate?.stickerFaceEditorViewController(self, didSelectPaid: layer, layers: newPaidLayers, with: price, layerType: type)
        } else {
            layers = replaceCurrentLayer(with: layer, section: section)
            delegate?.stickerFaceEditorViewController(self, didUpdate: layers)
            updateSelectedLayers()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension StickerFaceEditorViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageController = viewController as? StickerFaceEditorPageController else { return nil }
        if pageController.index == 0 {
            return nil
        }
        return viewControllers?[pageController.index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageController = viewController as? StickerFaceEditorPageController else { return nil }
        if pageController.index == (viewControllers?.count ?? 0) - 1 {
            return nil
        }
        return viewControllers?[pageController.index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed || !finished {
            return
        }
        
        if let viewController = mainView.pageViewController.viewControllers?.first as? StickerFaceEditorPageController {
            headers.enumerated().forEach { $0.element.isSelected = $0.element.title == viewController.sectionModel.editorSubsection.name }
            headerAdapter.reloadData(completion: nil)
            
            mainView.headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: viewController.index), at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - StikerFaceEditorDelegate
extension StickerFaceEditorViewController: StikerFaceEditorDelegate {
    func updateLayers(_ layers: String) {
        self.layers = layers
        updateSelectedLayers()
    }
    
    func layersWithoutBackground(_ layers: String) -> (background: String, layers: String) {
        var layers = layers
        var backgroundLayer = "0"
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        var layersArray = layers.components(separatedBy: ";")
        let backgroundLayers = objects.first(where: { model in
            model.editorSubsection.name == "background"
        })
        
        if let backLayers = backgroundLayers {
            backLayers.editorSubsection.layers?.forEach({ layer in
                if let index = layersArray.firstIndex(where: { $0 == layer }) {
                    backgroundLayer = layer
                    layersArray.remove(at: index)
                }
            })
        }
        
        let resultLayers = layersArray.joined(separator: ";")
        return (background: backgroundLayer, layers: resultLayers)
    }
}
