import UIKit
import IGListKit
import WebKit

protocol StickerFaceEditorPageDelegate: AnyObject {
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, emptyView forListAdapter: ListAdapter) -> UIView?
    func stickerFaceEditorPageController(_ controller: StickerFaceEditorPageController, didSelect layer: String, section: Int)
}

class StickerFaceEditorPageController: ViewController<StickerFaceEditorPageView> {

    struct LayerForRender: Equatable {
        let section: String
        let layer: String
    }
    
    weak var delegate: StickerFaceEditorPageDelegate?
    weak var editorDelegate: StickerFaceEditorDelegate?
    
    let decodingQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).decodingQueue")
    
    var sectionModel: EditorSubsectionSectionModel
    var index = 0
    var requestId = 0
    var layersForRender = [LayerForRender]()
    var isRendering: Bool = false
    var isRenderReady: Bool = true
    
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
        
    private func renderLayer() {
        guard let layer = layersForRender.first, !isRendering, isRenderReady else {
            adapter.reloadData()
            return
        }
        
        isRendering = true

        let renderLayers = createRenderLayers(layers: layer.layer, section: layer.section)
        StickerLoader.shared.renderLayer(renderLayers) { [weak self] image in
            guard let self = self else { return }
            
            self.layersForRender.remove(at: 0)
            
            if self.sectionModel.newLayersImages != nil {
                self.sectionModel.newLayersImages?[layer.layer] = image
            } else {
                self.sectionModel.newLayersImages = [layer.layer: image]
            }
            
            if self.sectionModel.oldLayersImages != nil {
                self.sectionModel.oldLayersImages?[layer.layer] = image
            } else {
                self.sectionModel.oldLayersImages = [layer.layer: image]
            }
            
            self.isRendering = false
            self.renderLayer()
        }
    }
    
    private func createRenderLayers(layers: String, section: String) -> String {
        var neededLayers = ""
        let allLayers = editorDelegate?.replaceCurrentLayers(with: layers, with: nil, isCurrent: true)
        let layersWitoutBack = editorDelegate?.layersWithout(section: "background", layers: allLayers ?? "")
        let layersWithoutClothing = editorDelegate?.layersWithout(section: "clothing", layers: layersWitoutBack?.layers ?? "")
        
        if layers == "0" || layers == "" {
            neededLayers = layers
        } else if section == "background" {
            neededLayers = layersWitoutBack?.sectionLayer ?? ""
        } else if section == "clothing" {
            neededLayers = layersWithoutClothing?.sectionLayer ?? ""
        } else {
            neededLayers = layersWithoutClothing?.layers ?? ""
        }

        neededLayers = neededLayers.replacingOccurrences(of: ";1;", with: ";")
        neededLayers = neededLayers.replacingOccurrences(of: ";0;", with: ";")
        neededLayers = neededLayers.replacingOccurrences(of: ";25;", with: ";")
        neededLayers = neededLayers.replacingOccurrences(of: ";273;", with: ";")
        
        return neededLayers
    }
}

// MARK: - ListAdapterDataSource
extension StickerFaceEditorPageController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [sectionModel]
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
    
    func stickerFaceEditor(_ controller: StickerFaceEditorSectionController, needRedner forLayer: String, section: String) {
        let layerForRender = LayerForRender(section: section, layer: forLayer)
        if !layersForRender.contains(layerForRender) {
            layersForRender.append(layerForRender)
            renderLayer()
        }
    }
    
    func stickerFaceEditor(_ controller: StickerFaceEditorSectionController, didSelect layer: String, section: Int) {
        delegate?.stickerFaceEditorPageController(self, didSelect: layer, section: index)
    }
    
    func stickerFaceEditor(_ controller: StickerFaceEditorSectionController, willDisplay header: String, in section: Int) { }    
}
