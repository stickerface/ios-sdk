import Foundation
import IGListKit
import SkeletonView

protocol StickerFaceEditorSectionControllerDelegate: AnyObject {
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, didSelect layer: String, section: Int)
    func stickerFaceEditorSectionController(_ controller: StickerFaceEditorSectionController, willDisplay header: String, in section: Int)
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
        supplementaryViewSource = self
    }
    
    override func numberOfItems() -> Int {
        var numberOfItems = 0
        
        if let colors = sectionModel.editorSubsection.colors, colors.count > 0 {
            layerColors = colors.map({ LayerColorEmbeddedSectionModel(color: $0) })
            layerColors.forEach { layerColor in
                layerColor.isSelected = String(layerColor.color.id) == sectionModel.selectedColor
            }
            numberOfItems += 1
        }
        
        if let layersCount = sectionModel.editorSubsection.layers?.count {
            numberOfItems += layersCount
        }
        
        return numberOfItems
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        if layerColors.count > 0 && index == 0 {
            return CGSize(width: collectionContext!.containerSize.width, height: 72.0)
        } else {
            return CGSize(side: collectionContext!.containerSize.width / 3.0)
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        if layerColors.count > 0 && index == 0 {
            let cell = collectionContext!.dequeue(of: LayerColorSelectorEmbeddedCell.self, for: self, at: index)
            
            return configure(cell: cell)
        } else {
            let index = layerColors.count > 0 ? index - 1 : index
            let cell = collectionContext!.dequeue(of: EditorLayerCollectionCell.self, for: self, at: index)
        
            return configure(cell: cell, layer: sectionModel.editorSubsection.layers?[index])
        }
    }
    
    private func configure(cell: LayerColorSelectorEmbeddedCell) -> LayerColorSelectorEmbeddedCell {
        adapter.collectionView = cell.collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        if let index = layerColors.firstIndex(where: { String($0.color.id) == sectionModel.selectedColor }) {
            cell.colorSelectionIndicatorView.tintColor = UIColor(hex: layerColors[index].color.hash)
            cell.collectionView.scrollToItem(at: IndexPath(item: 0, section: index), at: .centeredHorizontally, animated: true)
        }
        
        return cell
    }
    
    private func configure(cell: EditorLayerCollectionCell, layer: String?) -> EditorLayerCollectionCell {
        guard let layer = layer else {
            return cell
        }
        
        let imageSide = 172
        let url = "https://stickerface.io/api/section/png/\(layer)?size=\(imageSide)"
        
        if cell.layerImageView.image == nil {
            cell.layerImageView.showSkeleton()
        }
        
        ImageLoader.setImage(url: url, imgView: cell.layerImageView) { result in
            switch result {
            case .success: cell.layerImageView.hideSkeleton()
            case .failure: break
            }
        }
        
        if let price = sectionModel.prices["\(layer)"] {
            cell.coinsButton.isHidden = false
            cell.coinsButton.setTitle("\(price)", for: .normal)
        }
        
        cell.layerImageView.backgroundColor = sectionModel.selectedLayer == layer ? UIColor(libraryNamed: "stickerFaceInput") : .clear
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        precondition(object is EditorSubsectionSectionModel)
        sectionModel = object as? EditorSubsectionSectionModel
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        
        let index = layerColors.count > 0 ? index - 1 : index
        if let layer = sectionModel.editorSubsection.layers?[index] {
            delegate?.stickerFaceEditorSectionController(self, didSelect: layer, section: section)
        }
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

// MARK: - ListSupplementaryViewSource
extension StickerFaceEditorSectionController: ListSupplementaryViewSource {
    
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        let view = collectionContext!.dequeue(ofKind: UICollectionElementKindSectionHeader, for: self, of: EditorSectionHeaderView.self, at: index)
        view.titleLabel.text = sectionModel.editorSubsection.name.uppercased()
        
        return view
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 56.0)
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

// MARK: - ScrollViewDelegate
extension StickerFaceEditorSectionController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPath = centeredIndexPath(), layerColors.count > indexPath.section {
            let color = layerColors[indexPath.section].color
            delegate?.stickerFaceEditorSectionController(self, didSelect: String(color.id), section: section)
        }
    }

}
