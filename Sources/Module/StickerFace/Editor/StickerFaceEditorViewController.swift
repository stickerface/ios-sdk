import UIKit
import IGListKit

enum LayerType {
    case layers
    case background
    case NFT
}

protocol StickerFaceEditorControllerDelegate: AnyObject {
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didUpdate layers: String)
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didUpdateBackground layers: String)
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didSave layers: String)
    func stickerFaceEditor(_ controller: StickerFaceEditorViewController, didSelectPaid layer: String, layers withLayer: String, with price: Int, layerType: LayerType)
    func stickerFaceEditor(didLoadLayers controller: StickerFaceEditorViewController)
}

protocol StickerFaceEditorDelegate: AnyObject {
    func setGender(_ gender: SFDefaults.Gender)
    func updateLayers(_ layers: String)
    func layersWithout(section: String, layers: String) -> (sectionLayer: String, layers: String)
    func replaceCurrentLayers(with layer: String, with color: String?, isCurrent: Bool) -> String
}

class StickerFaceEditorViewController: ViewController<StickerFaceEditorView> {
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    weak var delegate: StickerFaceEditorControllerDelegate?
    
    var layers: String = ""
    var currentLayers: String = "" {
        didSet {
            let isEnabled = !SFDefaults.wasEdited || !Utils.compareLayers(currentLayers, layers)
            mainView.saveButton.isUserInteractionEnabled = isEnabled
            mainView.saveButton.backgroundColor = isEnabled ? .sfAccentBrand : .sfDisabled
        }
    }
    
    private let provider = StickerFaceEditorProvider()
    private var editor: Editor?
    private var loadingState = LoadingState.loading
    private var prices: [String: Int] = [:]
    private var headers: [EditorHeaderSectionModel] = []
    private var objects: [EditorSectionModel] = []
    private var viewControllers: [UIViewController]? = []
    
    private lazy var headerAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        mainView.notConnectButton.addTarget(self, action: #selector(notConnectButtonTapped), for: .touchUpInside)
        
        headerAdapter.collectionView = mainView.headerCollectionView
        headerAdapter.dataSource = self
        headerAdapter.scrollViewDelegate = self
        
        addChild(mainView.pageViewController)
        
        mainView.pageViewController.didMove(toParent: self)
        mainView.pageViewController.dataSource = self
        mainView.pageViewController.delegate = self
        
        loadEditor()
    }
    
    // MARK: Private actions
    
    @objc private func saveButtonTapped() {
        layers = currentLayers
        SFDefaults.wasEdited = true
        delegate?.stickerFaceEditor(self, didSave: layers)
    }
    
    @objc private func notConnectButtonTapped() {
        mainView.loaderView.isHidden = false
        loadEditor()
    }
    
    // MARK: Public methods
    
    func updateSelectedLayers(_ selectedLayer: String? = nil) {
        var layers = currentLayers
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        let layersArray = layers.components(separatedBy: ";")
        
        objects.enumerated().forEach { index, object in
            object.sections.forEach { subsection in
                let prevColor = subsection.selectedColor
                subsection.selectedColor = nil
                subsection.selectedLayer = "0"
                
                if let editorLayers = subsection.editorSubsection.layers,
                   let layer = editorLayers.first(where: { layersArray.contains($0) }) {
                    subsection.selectedLayer = layer
                }
                
                if subsection.selectedLayer != selectedLayer {
                    subsection.newLayersImages = nil
                }
                
                if let colorLayers = subsection.editorSubsection.colors?.compactMap({ String($0.id) }),
                   let colorId = layersArray.first(where: { colorLayers.contains($0) }) {
                    subsection.selectedColor = colorId
                    
                    if prevColor != colorId {
                        subsection.newLayersImages = nil
                    }
                }
                
                if let viewController = viewControllers?[index] as? StickerFaceEditorPageController {
                    viewController.sectionModel = object
                    
                    if index == headers.firstIndex(where: { $0.isSelected }) {
                        viewController.needUpdate()
                    }
                }
            }
        }
    }
    
    // MARK: Private methods
    
    private func loadEditor() {
        provider.loadEditor { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let editor):
                self.mainView.separator.isHidden = false
                self.mainView.saveButton.isHidden = false
                self.mainView.notConnectButton.isHidden = true
                self.mainView.notConnectLabel.isHidden = true
                
                self.editor = editor
                SFDefaults.avatarCollection = editor.nft.avatarCollection
                SFDefaults.avatarMintPrice = Double(editor.nft.avatarMintPrice) / 1000000000.0
                self.setupSections(needSetDefault: false, for: SFDefaults.gender)
                
                self.delegate?.stickerFaceEditor(didLoadLayers: self)
            
            case .failure:
                if self.loadingState == .failed {
                    self.mainView.loaderView.showError("Error load editor")
                }
                
                self.loadingState = .failed
                self.mainView.separator.isHidden = true
                self.mainView.saveButton.isHidden = true
                self.mainView.notConnectButton.isHidden = false
                self.mainView.notConnectLabel.isHidden = false
            }
        }
    }
    
    private func setupSections(needSetDefault: Bool, for gender: SFDefaults.Gender) {
        guard let editor = editor else { return }
        let needSetupGender = objects.isEmpty
        
        defer {
            if needSetupGender {
                setupSections(needSetDefault: false, for: SFDefaults.gender)
            }
        }
        
        let sections = gender == .male ? editor.sections.man : editor.sections.woman
                
        headers = sections.compactMap { section in
            guard section.name != "Clothing", section.name != "Accessories" else { return nil }
            return EditorHeaderSectionModel(title: section.name)
        }
        
        headers.first?.isSelected = true
        headerAdapter.reloadData(completion: nil)
        
        prices = editor.prices
                
        objects = sections.compactMap({ section in
            guard section.name != "Clothing", section.name != "Accessories" else { return nil }
            
            let models = section.subsections.map { subsection -> EditorSubsectionSectionModel in
                var layers = subsection.layers
                if subsection.name == "background" {
                    layers = layers?
                        .filter { prices[$0] == nil || prices[$0] == 0 }
                        .filter { $0 != "0" }
                }

                let editorSubsection = EditorSubsection(
                    name: subsection.name,
                    layers: layers,
                    colors: subsection.colors?.reversed()
                )
                
                let model = EditorSubsectionSectionModel(editorSubsection: editorSubsection, prices: prices)
                model.selectedLayer = "0"
                
                return model
            }
            
            return EditorSectionModel(name: section.name, sections: models)
        })
        
        if needSetupGender {
            if layersWithout(section: "hair", layers: layers).sectionLayer == "0" {
                SFDefaults.gender = SFDefaults.gender == .male ? .female : .male
                return
            }
        }
        
        if needSetDefault {
            mainView.headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }

        viewControllers = objects.enumerated().map { index, object in
            let controller = StickerFaceEditorPageController(sectionModel: object)
            controller.delegate = self
            controller.editorDelegate = self
            controller.index = index
            
            return controller
        }
        
        updateSelectedLayers()
        loadingState = .loaded
        
        if let viewController = viewControllers?[0] {
            mainView.pageViewController.setViewControllers([viewController], direction: .reverse, animated: false)
        }
    }
    
    private func replaceCurrentLayer(with replacementLayer: String, subsection: Int, isCurrent: Bool) -> String {
        var layers = isCurrent ? currentLayers : layers
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        var layersArray = layers.components(separatedBy: ";").compactMap { layer -> String? in
            return layer != "" ? layer : nil
        }
        
        let section = headers.firstIndex(where: { $0.isSelected }) ?? 0
        let editorSubsection = objects[section].sections[subsection].editorSubsection
        
        if let editorLayers = editorSubsection.layers, editorLayers.contains(replacementLayer) {
            editorLayers.forEach { editorLayer in
                if let index = layersArray.firstIndex(where: { $0 == editorLayer }), layersArray[index] != "0" {
                    layersArray.remove(at: index)
                }
            }
        } else if let colorLayers = editorSubsection.colors?.compactMap({ String($0.id) }), colorLayers.contains(replacementLayer) {
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
}

// MARK: - ListAdapterDataSource
extension StickerFaceEditorViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] { headers }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let editorHeaderSectionController = EditorHeaderSectionController()
        editorHeaderSectionController.delegate = self
        
        return editorHeaderSectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { nil }
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
            
            return emptyView
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
        let isPaid = SFDefaults.wardrobe.contains(layer) || SFDefaults.paidBackgrounds.contains(layer)
        let subsection = section
        let section = headers.firstIndex(where: { $0.isSelected }) ?? 0
        
        if let price = prices["\(layer)"], !isPaid {
            let newPaidLayers = replaceCurrentLayer(with: layer, subsection: subsection, isCurrent: true)
            let type: LayerType = objects[section].name == "Background" ? .background : .NFT

            delegate?.stickerFaceEditor(self, didSelectPaid: layer, layers: newPaidLayers, with: price, layerType: type)
        } else {
            currentLayers = replaceCurrentLayer(with: layer, subsection: subsection, isCurrent: true)
            
            if objects[section].name == "Background" {
                delegate?.stickerFaceEditor(self, didUpdateBackground: currentLayers)
            } else {
                delegate?.stickerFaceEditor(self, didUpdate: currentLayers)
            }
            
            updateSelectedLayers(layer)
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
            headers.enumerated().forEach { $0.element.isSelected = $0.element.title == viewController.sectionModel.name }
            headerAdapter.reloadData(completion: nil)
            
            mainView.headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: viewController.index), at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - StickerFaceEditorDelegate
extension StickerFaceEditorViewController: StickerFaceEditorDelegate {
    func replaceCurrentLayers(with layer: String, with color: String?, isCurrent: Bool) -> String {
        guard
            let section = headers.firstIndex(where: { $0.isSelected }),
            let subsection = objects[section].sections.firstIndex(where: { $0.editorSubsection.layers?.contains(layer) ?? false })
        else { return "" }
        
        var layers = replaceCurrentLayer(with: layer, subsection: subsection, isCurrent: isCurrent)
        
        if let color = color {
            let tmpLayers = currentLayers
            if isCurrent {
                currentLayers = layers
                layers = replaceCurrentLayer(with: color, subsection: subsection, isCurrent: isCurrent)
                currentLayers = tmpLayers
            } else {
                self.layers = layers
                layers = replaceCurrentLayer(with: color, subsection: subsection, isCurrent: isCurrent)
                self.layers = tmpLayers
            }
        }
        
        return layers
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
                
        let subsection = objects.flatMap { $0.sections }.compactMap { $0.editorSubsection }.first(where: { $0.name == section })
        
        if let subsection = subsection {
            subsection.layers?.forEach { layer in
                if let index = layersArray.firstIndex(where: { $0 == layer }) {
                    sectionLayer = layer
                    layersArray.remove(at: index)
                }
            }
        }
        
        let resultLayers = layersArray.joined(separator: ";")
        return (sectionLayer: sectionLayer, layers: resultLayers)
    }
    
    func setGender(_ gender: SFDefaults.Gender) {
        StickerLoader.shared.clearRenderQueue()
        currentLayers = gender == .male ? StickerLoader.defaultLayers : StickerLoader.defaultWomanLayers
        
        setupSections(needSetDefault: true, for: gender)
        delegate?.stickerFaceEditor(self, didUpdate: currentLayers)
    }
}

// MARK: - UIScrollViewDelegate
extension StickerFaceEditorViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut) {
            let contentOffsetX = scrollView.contentOffset.x
            self.mainView.leftGradientView.alpha = contentOffsetX < 10.0 ? 0 : 1
            
            let maxContentOffsetX = max(0, scrollView.maxContentOffset.x - 10.0)
            self.mainView.rightGradientView.alpha = maxContentOffsetX < contentOffsetX ? 0 : 1
        }
    }
}
