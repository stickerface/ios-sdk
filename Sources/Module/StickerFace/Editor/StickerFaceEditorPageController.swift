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
    
    var sectionModel: EditorSubsectionSectionModel
    var index = 0
    var requestId = 0
    var layersForRender = [LayerForRender]()
    var isRendering: Bool = false
    var isRenderRedy: Bool = false
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    init(sectionModel: EditorSubsectionSectionModel) {
        self.sectionModel = sectionModel
        super.init(nibName: nil, bundle: nil)
        
        if let url = URL(string: "https://stickerface.io/render.html") {
            mainView.renderWebView.load(URLRequest(url: url))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.collectionView = mainView.collectionView
        adapter.dataSource = self
        
        mainView.renderWebView.navigationDelegate = self
        
        let handler = AvatarRenderResponseHandler()
        handler.delegate = self
        
        mainView.renderWebView.configuration.userContentController.add(handler, name: handler.name)
    }
        
    private func renderLayer() {
        guard let layer = layersForRender.first, !isRendering, isRenderRedy else {
            adapter.reloadData()
            return
        }
        
        isRendering = true
        let id = getNextRequestId()
        let renderFunc = createRenderFunc(requestId: id, layers: layer.layer, size: Int(AvatarView.Layout.avatarImageViewHeight) * 4, section: layer.section)
        
        mainView.renderWebView.evaluateJavaScript(renderFunc)
    }
    
    private func createRenderFunc(requestId: Int, layers: String, size: Int, section: String) -> String {
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
        return "renderPNG(\"\(neededLayers)\", \(requestId), \(size), {partial:true})"
    }
    
    private func getNextRequestId() -> Int {
        let current = requestId
        requestId = (current + 1) % Int.max
        
        return current
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
extension StickerFaceEditorPageController: StickerFaceEditorSectionControllerDelegate {
    func needUpdate() {
        adapter.reloadData()
    }
    
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, needRedner forLayer: String, section: String) {
        let layerForRender = LayerForRender(section: section, layer: forLayer)
        if !layersForRender.contains(layerForRender) {
            layersForRender.append(layerForRender)
            renderLayer()
        }
    }
    
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, didSelect layer: String, section: Int) {
        delegate?.stickerFaceEditorPageController(self, didSelect: layer, section: index)
    }
    
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, willDisplay header: String, in section: Int) { }
}

// MARK: - AvatarRenderResponseHandlerDelegate
extension StickerFaceEditorPageController: AvatarRenderResponseHandlerDelegate {
    
    func onImageReady(base64: String) {
        if let data = Data(base64Encoded: base64, options: []), let layer = layersForRender.first {
            let image = UIImage(data: data)
            layersForRender.remove(at: 0)
            
            if sectionModel.newLayersImages != nil {
                sectionModel.newLayersImages?[layer.layer] = image
            } else {
                sectionModel.newLayersImages = [layer.layer: image ?? UIImage()]
            }
            
            if sectionModel.oldLayersImages != nil {
                sectionModel.oldLayersImages?[layer.layer] = image
            } else {
                sectionModel.oldLayersImages = [layer.layer: image ?? UIImage()]
            }
            
            isRendering = false
            renderLayer()
        }
    }
    
}

// MARK: - WKScriptMessageHandler
extension StickerFaceEditorPageController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isRenderRedy = true
        renderLayer()
    }
    
}

