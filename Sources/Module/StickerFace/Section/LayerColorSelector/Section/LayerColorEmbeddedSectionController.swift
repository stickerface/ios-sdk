import Foundation
import IGListKit

protocol LayerColorEmbeddedSectionControllerDelegate: AnyObject {
    func layerColorEmbeddedSectionController(_ controller: LayerColorEmbeddedSectionController, didSelect color: EditorColor)
}

class LayerColorEmbeddedSectionController: ListSectionController {
    
    private var sectionModel: LayerColorEmbeddedSectionModel!
    
    weak var delegate: LayerColorEmbeddedSectionControllerDelegate?
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override init() {
        super.init()
        
        inset = UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 6.0)
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(side: 52.0)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeue(of: LayerColorEmbeddedCell.self, for: self, at: index)
    
        return configure(cell: cell)
    }
    
    private func configure(cell: LayerColorEmbeddedCell) -> LayerColorEmbeddedCell {
        cell.colorView.backgroundColor = UIColor(hex: sectionModel.color.hash)
        
        cell.colorSelectionIndicatorView.isHidden = !sectionModel.isSelected
        cell.colorSelectionIndicatorView.tintColor = UIColor(hex: sectionModel.color.hash)
                
        return cell
    }
    
    override func didUpdate(to object: Any) {
        precondition(object is LayerColorEmbeddedSectionModel)
        sectionModel = object as? LayerColorEmbeddedSectionModel
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        
        delegate?.layerColorEmbeddedSectionController(self, didSelect: sectionModel.color)
    }
    
    
}
