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
        
        var size = CGSize(side: (UIScreen.main.bounds.width - 16 - 12 - 16)/2).maxSide
        let renderLayers = createRenderLayers(layer: layer.layer, subsection: layer.subsection)
        
        switch layer.subsection.lowercased() {
        case "eyes": size *= 1.6
        case "eyebrows": size *= 2
        case "mouth": size *= 4
        case "nose": size *= 3
            
        default: break
        }
        
        StickerLoader.shared.renderLayer(renderLayers, size: size) { [weak self] image in
            guard let self = self else { return }
            
            self.layersForRender.remove(at: 0)
            
            if let sectionModel = self.sectionModel.sections.first(where: { $0.editorSubsection.name == layer.subsection }) {
                
                let image = self.createScaledImage(for: sectionModel.editorSubsection.name, image: image)
                
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
    
    private func createRenderLayers(layer: String, subsection: String) -> String {
        guard layer != "0", layer != "" else { return layer }
        var neededLayers = ""
        let helper = EditorHelper.shared
        
        let layersNoSubsection = helper.removeLayer(in: subsection, from: editorDelegate?.currentLayers ?? "")
        let allLayers = layersNoSubsection.layers + ";\(layer);"
        let layersNoBack = helper.removeLayer(in: "background", from: allLayers)
        
        switch subsection.lowercased() {
        case "background":
            return layersNoBack.removedLayer
                        
        case "eyebrows", "eyes", "nose":
            var layers = helper.removeLayer(in: "necklace", from: layersNoBack.layers).layers
            layers = helper.removeLayer(in: "beard", from: layers).layers
            layers = helper.removeLayer(in: "glasses", from: layers).layers
            layers = helper.removeLayer(in: "bristle", from: layers).layers
            layers = helper.removeLayer(in: "moustache", from: layers).layers
            layers = helper.removeLayer(in: "cap", from: layers).layers
            layers = helper.removeLayer(in: "clothing", from: layers).layers
            layers = helper.removeLayer(in: "t-shirt", from: layers).layers
            
            neededLayers = layers
            
        case "head", "facelines", "freckles", "mouth":
            var layers = helper.removeLayer(in: "bristle", from: layersNoBack.layers).layers
            layers = helper.removeLayer(in: "moustache", from: layers).layers
            layers = helper.removeLayer(in: "beard", from: layers).layers
            layers = helper.removeLayer(in: "t-shirt", from: layers).layers
            layers = helper.removeLayer(in: "clothing", from: layers).layers
            layers = helper.removeLayer(in: "necklace", from: layers).layers
            
            neededLayers = layers
            
        case "hair", "moustache", "beard", "bristle":
            var layers = helper.removeLayer(in: "cap", from: layersNoBack.layers).layers
            layers = helper.removeLayer(in: "t-shirt", from: layers).layers
            layers = helper.removeLayer(in: "necklace", from: layers).layers
            layers = helper.removeLayer(in: "clothing", from: layers).layers
            
            neededLayers = layers
            
        case "t-shirt", "clothing", "necklace":
            return layersNoBack.layers
            
        default:
            var layers = helper.removeLayer(in: "clothing", from: layersNoBack.layers).layers
            layers = helper.removeLayer(in: "t-shirt", from: layers).layers
            layers = helper.removeLayer(in: "necklace", from: layers).layers
            
            neededLayers = layers
        }
        

        let layersArray = neededLayers.split(separator: ";")
        let fireLayers = ["1", "0", "25", "273"]
        
        let neededArray = layersArray.compactMap { layer -> String? in
            guard !fireLayers.contains(String(layer)) else { return nil }
            return String(layer)
        }
        
        return neededArray.joined(separator: ";")
    }
    
    private func createScaledImage(for section: String, image: UIImage) -> UIImage {
        switch section.lowercased() {
        case "eyes":
            let sideLength = min(image.size.width / 1.6, image.size.height / 1.6)
            
            let sourceSize = image.size
            let xOffset = (sourceSize.width - sideLength) / 2.0
            let yOffset = (sourceSize.height - sideLength) / 1.5
            
            let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
            
            let sourceCGImage = image.cgImage!
            let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
            
            return UIImage(cgImage: croppedCGImage)
            
        case "eyebrows":
            let sideLength = min(image.size.width / 2.0, image.size.height / 2.0)
            
            let sourceSize = image.size
            let xOffset = (sourceSize.width - sideLength) / 2.0
            let yOffset = (sourceSize.height - sideLength) / 1.7
            
            let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
            
            let sourceCGImage = image.cgImage!
            let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
            
            return UIImage(cgImage: croppedCGImage)
            
        case "mouth":
            let sideLength = min(image.size.width / 4, image.size.height / 4)
            
            let sourceSize = image.size
            let xOffset = (sourceSize.width - sideLength) / 2.0
            let yOffset = (sourceSize.height - sideLength) / 1.12
            
            let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
            
            let sourceCGImage = image.cgImage!
            let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
            
            return UIImage(cgImage: croppedCGImage)
            
        case "nose":
            let sideLength = min(image.size.width / 3, image.size.height / 3)
            
            let sourceSize = image.size
            let xOffset = (sourceSize.width - sideLength) / 2
            let yOffset = (sourceSize.height - sideLength) / 1.25
            
            let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
            
            let sourceCGImage = image.cgImage!
            let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
            
            return UIImage(cgImage: croppedCGImage)
            
        default:
            return image
        }
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
