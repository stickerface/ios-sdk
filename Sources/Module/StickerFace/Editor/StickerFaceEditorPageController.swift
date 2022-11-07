import UIKit
import IGListKit
import WebKit

protocol StickerFaceEditorPageDelegate: AnyObject {
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, emptyView forListAdapter: ListAdapter) -> UIView?
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, didSelect layer: String, section: Int)
}

class StickerFaceEditorPageController: ViewController<StickerFaceEditorPageView> {

    struct LayerForRender: Equatable {
        let subsection: String
        let layer: String
    }
    
    weak var delegate: StickerFaceEditorPageDelegate?
    weak var editorDelegate: StickerFaceEditorDelegate?
    
    let decodingQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).decodingQueue")
    
    var sectionModel: EditorSectionModel
    var index = 0
    var requestId = 0
    var layersForRender = [LayerForRender]()
    var isRendering: Bool = false
    
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    
    init(sectionModel: EditorSectionModel) {
        self.sectionModel = sectionModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layers = sectionModel.sections.flatMap { $0.editorSubsection.layers ?? [] }
        StickerLoader.shared.preloadLayers(layers)
        
        adapter.collectionView = mainView.collectionView
        adapter.dataSource = self 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adapter.reloadData()
    }
    
    private func renderLayer() {
        guard let layer = layersForRender.first, !isRendering else {
            adapter.reloadData()
            return
        }
        
        isRendering = true
        
        let renderLayers = createRenderLayers(layers: layer.layer, subsection: layer.subsection)
        
        StickerLoader.shared.renderLayer(renderLayers) { [weak self] image in
            guard let self = self else { return }
            
            self.layersForRender.remove(at: 0)
            
            if let sectionModel = self.sectionModel.sections.first(where: { $0.editorSubsection.name == layer.subsection }) {
                if sectionModel.newLayersImages != nil {
                    sectionModel.newLayersImages?[layer.layer] = image
                } else {
                    sectionModel.newLayersImages = [layer.layer: image]
                }

                if sectionModel.oldLayersImages != nil {
                    sectionModel.oldLayersImages?[layer.layer] = image
                } else {
                    sectionModel.oldLayersImages = [layer.layer: image]
                }
            }
            
            self.isRendering = false
            self.renderLayer()
        }
    }
    
    private func createRenderLayers(layers: String, subsection: String) -> String {
        var neededLayers = ""
        let helper = EditorHelper.shared
        
        let layersNoSubsection = helper.removeLayer(in: subsection, from: editorDelegate?.currentLayers ?? "")
        let allLayers = layersNoSubsection.layers + ";\(layers);"
        let layersNoBack = helper.removeLayer(in: "background", from: allLayers)
        let layersNoClothing = helper.removeLayer(in: "clothing", from: layersNoBack.layers)
        
        if layers == "0" || layers == "" {
            neededLayers = layers
        } else if subsection == "background" {
            return layersNoBack.removedLayer
        } else if subsection == "clothing" {
            return layersNoBack.layers
        } else {
            neededLayers = layersNoClothing.layers
        }

        let layersArray = neededLayers.split(separator: ";")
        let fireLayers = ["1", "0", "25", "273", layersNoClothing.removedLayer]
        
        let neededArray = layersArray.compactMap { layer -> String? in
            guard !fireLayers.contains(String(layer)) else { return nil }
            return String(layer)
        }
        
        return neededArray.joined(separator: ";")
    }
    
    private func appendRenderLayer(section: Int, index: Int) {
        guard
            let layer = sectionModel.sections[section].editorSubsection.layers?[index],
            layer != "0",
            sectionModel.sections[section].newLayersImages?[layer] == nil
        else { return }
        
        let subsectionName = sectionModel.sections[section].editorSubsection.name
        let layerForRender = LayerForRender(subsection: subsectionName, layer: layer)
        
        if !layersForRender.contains(layerForRender) {
            layersForRender.append(layerForRender)
            renderLayer()
        }
    }
}

// MARK: - ListAdapterDataSource
extension StickerFaceEditorPageController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return sectionModel.sections
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = StickerFaceEditorSectionController()
        sectionController.delegate = self
        
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return delegate?.stickerFaceEditorPageController(self, emptyView: listAdapter)
    }
}

// MARK: - StickerFaceEditorSectionControllerDelegate
extension StickerFaceEditorPageController: StickerFaceEditorSectionDelegate {
    func needUpdate() {
        adapter.reloadData()
    }
        
    func stickerFaceEditor(_ controller: StickerFaceEditorSectionController, didSelect layer: String, section: Int) {
        delegate?.stickerFaceEditorPageController(self, didSelect: layer, section: section)
    }
    
    func stickerFaceEditor(_ controller: StickerFaceEditorSectionController, willDisplay header: String, in section: Int, at index: Int) {
        appendRenderLayer(section: section, index: index)
        
        let count = sectionModel.sections[section].editorSubsection.layers?.count ?? 0
        if count > index + 2 {
            appendRenderLayer(section: section, index: index + 2)
        }
    }
}
