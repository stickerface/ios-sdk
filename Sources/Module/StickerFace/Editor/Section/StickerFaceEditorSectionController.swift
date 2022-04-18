import Foundation
import IGListKit
import SkeletonView

protocol StickerFaceEditorSectionControllerDelegate: AnyObject {
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, didSelect layer: String, section: Int)
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, willDisplay header: String, in section: Int)
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, needRedner forLayer: String)
}

class StickerFaceEditorSectionController: ListSectionController {
    
    private var sectionModel: EditorSubsectionSectionModel!
    private let cellTemplate = EditorLayerCollectionCell()
    private var layerColors: [LayerColorEmbeddedSectionModel] = []
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: viewController, workingRangeSize: 0)
    }()
    
    weak var delegate: StickerFaceEditorSectionControllerDelegate?
            
    override init() {
        super.init()
        
        displayDelegate = self
    }
    
    override func didUpdate(to object: Any) {
        precondition(object is EditorSubsectionSectionModel)
        sectionModel = object as? EditorSubsectionSectionModel
        
        if sectionModel.editorSubsection.name == "background" {
            inset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
            minimumLineSpacing = 16.0
            minimumInteritemSpacing = 22.0
        } else {
            minimumLineSpacing = 12.0
            minimumInteritemSpacing = 12.0
        }
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        
        let layerIndex: Int
        if layerColors.count > 0 {
            layerIndex = index - 3
        } else if sectionModel.editorSubsection.name == "background" {
            layerIndex = index
        } else {
            layerIndex = index - 1
        }
        if let layer = sectionModel.editorSubsection.layers?[layerIndex] {
            delegate?.stickerFaceEditorSectionController(self, didSelect: layer, section: section)
        }
    }
    
    override func numberOfItems() -> Int {
        var numberOfItems = sectionModel.editorSubsection.name == "background" ? 0 : 1
        
        if let colors = sectionModel.editorSubsection.colors, colors.count > 0 {
            layerColors = colors.map { LayerColorEmbeddedSectionModel(color: $0) }
            layerColors.forEach { layerColor in
                layerColor.isSelected = String(layerColor.color.id) == sectionModel.selectedColor
            }
            
            numberOfItems += 2
        }
        
        if let layersCount = sectionModel.editorSubsection.layers?.count {
            numberOfItems += layersCount
        }
        
        return numberOfItems
    }
    
    // TODO: need fit size
    // TODO: fix colors left spacing
    override func sizeForItem(at index: Int) -> CGSize {
        // size for background layers
        if sectionModel.editorSubsection.name == "background" {
            return CGSize(width: 100.0, height: 144.0)
        }
        
        // size for titels
        if index == 0 || (layerColors.count > 0 && index == 2) {
            return CGSize(width: collectionContext!.containerSize.width, height: 30.0)
        }
        
        // size for colors
        if layerColors.count > 0 && index == 1 {
            return CGSize(width: collectionContext!.containerSize.width, height: 52.0)
        }
        
        // size for layers
        return CGSize(width: (UIScreen.main.bounds.width - 16 - 12 - 16)/2, height: 188)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        if index == 0 && sectionModel.editorSubsection.name != "background" {
            let cell = collectionContext!.dequeue(of: EditorSectionHeaderCell.self, for: self, at: index)
            cell.titleLabel.text = layerColors.count > 0 ? "commonColorCups".libraryLocalized : sectionModel.editorSubsection.name.uppercased()
            
            return cell
        } else if layerColors.count > 0 && index == 1 {
            let cell = collectionContext!.dequeue(of: LayerColorSelectorEmbeddedCell.self, for: self, at: index)
            
            return configure(cell: cell)
        } else if layerColors.count > 0 && index == 2 {
            let cell = collectionContext!.dequeue(of: EditorSectionHeaderCell.self, for: self, at: index)
            cell.titleLabel.text = sectionModel.editorSubsection.name.uppercased()
            
            return cell
        } else {
            let layerIndex: Int
            if layerColors.count > 0 {
                layerIndex = index - 3
            } else if sectionModel.editorSubsection.name == "background" {
                layerIndex = index
            } else {
                layerIndex = index - 1
            }
            
            let cell = collectionContext!.dequeue(of: EditorLayerCollectionCell.self, for: self, at: layerIndex)
        
            return configure(cell: cell, layer: sectionModel.editorSubsection.layers?[layerIndex])
        }
    }
    
    private func configure(cell: LayerColorSelectorEmbeddedCell) -> LayerColorSelectorEmbeddedCell {
        adapter.collectionView = cell.collectionView
        adapter.dataSource = self
        
        return cell
    }
    
    private func configure(cell: EditorLayerCollectionCell, layer: String?) -> EditorLayerCollectionCell {
        guard let layer = layer else {
            return cell
        }
        
        // TODO: need 'if' closure for NFT
        if sectionModel.editorSubsection.name == "background" {
            cell.layerType = .background
        } else if sectionModel.editorSubsection.name == "clothing" {
            cell.layerType = .NFT
        } else {
            cell.layerType = .layers
        }
                
        if let image = sectionModel.layersImages?[layer] {
            cell.contentView.hideSkeleton()
            cell.layerImageView.image = image
        } else {
            delegate?.stickerFaceEditorSectionController(self, needRedner: layer)
        }
        
        let isPaid = UserSettings.wardrobe.contains(layer) || UserSettings.paidBackgrounds.contains(layer)
        
        cell.setPrice(sectionModel.prices["\(layer)"], isPaid: isPaid)
        cell.setSelected(sectionModel.selectedLayer == layer)
        
        cell.titleLabel.text = "Honeysuckle"
        cell.noneImageView.isHidden = layer != "0"
        
        cell.setNeedsLayout()
        return cell
    }
    
    private func centeredIndexPath() -> IndexPath? {
        guard
            let collectionView = adapter.collectionView,
            let point = collectionView.superview?.convert(collectionView.center, to: collectionView)
        else {
            return nil
        }
        
        return collectionView.indexPathForItem(at: point)
    }
    
}

// MARK: - ListAdapterDataSource
extension StickerFaceEditorSectionController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return layerColors
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let layerColorEmbeddedSectionController = LayerColorEmbeddedSectionController()
        layerColorEmbeddedSectionController.delegate = self
        
        return layerColorEmbeddedSectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

// MARK: - LayerColorEmbeddedSectionControllerDelegate
extension StickerFaceEditorSectionController: LayerColorEmbeddedSectionControllerDelegate {
    
    func layerColorEmbeddedSectionController(_ controller: LayerColorEmbeddedSectionController, didSelect color: EditorColor) {
        delegate?.stickerFaceEditorSectionController(self, didSelect: String(color.id), section: section)
    }
    
}

// MARK: - ListDisplayDelegate
extension StickerFaceEditorSectionController: ListDisplayDelegate {

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if index <= numberOfItems() / 2 {
            delegate?.stickerFaceEditorSectionController(self, willDisplay: sectionModel.editorSubsection.name, in: section)
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {}
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {}
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {}

}
