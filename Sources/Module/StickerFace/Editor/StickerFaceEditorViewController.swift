import UIKit
import IGListKit

enum LayerType {
    case layers
    case background
    case NFT
}

protocol StickerFaceEditorViewControllerDelegate: AnyObject {
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didUpdate layers: String)
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSave layers: String)
    func stickerFaceEditorViewController(_ controller: StickerFaceEditorViewController, didSelectPaid layer: String, layers withLayer: String, with price: Int, layerType: LayerType)
    func stickerFaceEditorViewControllerDidLoadLayers(_ controller: StickerFaceEditorViewController)
}

protocol StickerFaceEditorDelegate: AnyObject {
    func updateLayers(_ layers: String)
    func layersWithout(section: String, layers: String) -> (sectionLayer: String, layers: String)
    func replaceCurrentLayers(with layer: String, with color: String?, isCurrent: Bool) -> String
}

class StickerFaceEditorViewController: ViewController<StickerFaceEditorView> {
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    weak var delegate: StickerFaceEditorViewControllerDelegate?
    
    var layers: String = ""
    var currentLayers: String = "" {
        didSet {
            mainView.saveButton.isUserInteractionEnabled = currentLayers != layers
            mainView.saveButton.backgroundColor = currentLayers == layers ? .sfDisabled : .sfAccentBrand
        }
    }
    
    private var loadingState = LoadingState.loading
    private let provider = StickerFaceEditorProvider()
    private var prices: [String: Int] = [:]
    private var headers: [EditorHeaderSectionModel] = []
    private var objects: [EditorSubsectionSectionModel] = []
    private var viewControllers: [UIViewController]? = []
    
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
        
    // MARK: Private actions
    
    @objc private func saveButtonTapped() {
        layers = currentLayers
        
        delegate?.stickerFaceEditorViewController(self, didSave: layers)
        
//        headers.enumerated().forEach { $0.element.isSelected = $0.offset == 0 }
//        objects.forEach { $0.newLayersImages = nil }
//        
//        mainView.saveButton.isUserInteractionEnabled = false
//        mainView.saveButton.backgroundColor = .sfDisabled
//        
//        headerAdapter.reloadData()
//        adapter.reloadData()
//        
//        mainView.headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
//        
//        if let vc = viewControllers?[0] as? StickerFaceEditorPageController {
//            vc.mainView.collectionView.scrollToTop(animated: false)
//            mainView.pageViewController.setViewControllers([vc], direction: .forward, animated: false)
//        }
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
                guard let self = self else { return }
                
                self.headers = editor.sections.flatMap({ $0.subsections }).compactMap({ subsection in
                    
                    if subsection.name != "background", subsection.name != "clothing", subsection.name != "glasses", subsection.name != "tattoos", subsection.name != "accessories", subsection.name != "masks" {
                        let model = EditorHeaderSectionModel(title: subsection.name)
                        return model
                    }
                    
                    return nil
                })
                self.headers.first?.isSelected = true
                self.headerAdapter.performUpdates(animated: true)
                
                self.prices = editor.prices
                
                // TODO: убрать говнокод
                self.prices["271"] = 2
                
                self.objects = editor.sections.flatMap({ $0.subsections }).map({ subsection in
                    let newSubsection = EditorSubsection(
                        name: subsection.name,
                        layers: subsection.layers,
                        colors: subsection.colors?.reversed()
                    )
                    let model = EditorSubsectionSectionModel(editorSubsection: newSubsection, prices: self.prices)
                    model.selectedLayer = "0"
                    
                    return model
                })

                self.viewControllers = self.objects.enumerated().map { index, object in
                    let controller = StickerFaceEditorPageController(sectionModel: object)
                    controller.delegate = self
                    controller.editorDelegate = self
                    controller.index = index
                    
                    return controller
                }
                
                self.updateSelectedLayers()
                self.loadingState = .loaded
                
                if let viewController = self.viewControllers?[0] {
                    self.mainView.pageViewController.setViewControllers([viewController], direction: .reverse, animated: true)
                }
                
                self.delegate?.stickerFaceEditorViewControllerDidLoadLayers(self)
            
            case .failure(let error):
                self?.mainView.loaderView.showError(error.localizedDescription)
                self?.loadingState = .failed
            }
        }
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
    
    private func replaceCurrentLayer(with replacementLayer: String, section: Int, isCurrent: Bool) -> String {
        var layers = isCurrent ? currentLayers : layers
        
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
        
        layers = layersArray.joined(separator: ";")
        if replacementLayer != "0" {
            layers += ";\(replacementLayer);"
        }
        
        return layers
    }
    
    private func receiveAvatar(avatarImage: UIImage?, personImage: UIImage?, backgroundImage: UIImage?) {
        guard
            let avatarImage = avatarImage,
            let personImage = personImage,
            let backgroundImage = backgroundImage
        else { return }
        
        let avatar = SFAvatar(avatarImage: avatarImage, personImage: personImage, backgroundImage: backgroundImage, layers: layers)
        StickerFace.shared.receiveAvatar(avatar)
    }
    
    // MARK: Public methods
    
    func updateSelectedLayers() {
        var layers = currentLayers
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        let layersArray = layers.components(separatedBy: ";")
        
        objects.enumerated().forEach { index, object in
            let prevColor = object.selectedColor
            object.selectedColor = nil
            object.selectedLayer = "0"
            
            if let header = headers.first(where: { $0.isSelected }), header.title.lowercased() != object.editorSubsection.name.lowercased() {
                object.newLayersImages = nil
            }
            
            if let editorLayers = object.editorSubsection.layers,
               let layer = editorLayers.first(where: { layersArray.contains($0) }) {
                object.selectedLayer = layer
            }
            
            if let colorLayers = object.editorSubsection.colors?.compactMap({ String($0.id) }),
               let colorId = layersArray.first(where: { colorLayers.contains($0) }) {
                object.selectedColor = colorId
                
                if prevColor != colorId {
                    object.newLayersImages = nil
                }
            }
            
            if let viewController = viewControllers?[index] as? StickerFaceEditorPageController {
                viewController.sectionModel = object
                viewController.needUpdate()
            }
        }
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
        currentLayers = replaceCurrentLayer(with: layer, section: section, isCurrent: true)
        delegate?.stickerFaceEditorViewController(self, didUpdate: currentLayers)
        updateSelectedLayers()
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

// MARK: - StickerFaceEditorDelegate
extension StickerFaceEditorViewController: StickerFaceEditorDelegate {
    func replaceCurrentLayers(with layer: String, with color: String?, isCurrent: Bool) -> String {
        let section = objects.firstIndex { sectionModel in
            return sectionModel.editorSubsection.layers?.contains(layer) ?? false
        }
        
        if let section = section {
            var layers = replaceCurrentLayer(with: layer, section: section, isCurrent: isCurrent)
            
            if let color = color {
                let tmpLayers = currentLayers
                if isCurrent {
                    currentLayers = layers
                    layers = replaceCurrentLayer(with: color, section: section, isCurrent: isCurrent)
                    currentLayers = tmpLayers
                } else {
                    self.layers = layers
                    layers = replaceCurrentLayer(with: color, section: section, isCurrent: isCurrent)
                    self.layers = tmpLayers
                }
            }
            
            return layers
        }
        
        return ""
    }
    
    func updateLayers(_ layers: String) {
        self.currentLayers = layers
        updateSelectedLayers()
    }
    
    func layersWithout(section: String, layers: String) -> (sectionLayer: String, layers: String) {
        var layers = layers
        var sectionLayer = "0"
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        var layersArray = layers.components(separatedBy: ";")
        let sectionLayers = objects.first(where: { model in
            model.editorSubsection.name == section
        })
        
        if let sectionLayers = sectionLayers {
            sectionLayers.editorSubsection.layers?.forEach({ layer in
                if let index = layersArray.firstIndex(where: { $0 == layer }) {
                    sectionLayer = layer
                    layersArray.remove(at: index)
                }
            })
        }
        
        let resultLayers = layersArray.joined(separator: ";")
        return (sectionLayer: sectionLayer, layers: resultLayers)
    }
}
