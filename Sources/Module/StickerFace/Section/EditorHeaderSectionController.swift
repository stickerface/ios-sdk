import Foundation
import IGListKit

protocol EditorHeaderSectionControllerDelegate: AnyObject {
    func editorHeaderSectionController(_ controller: EditorHeaderSectionController, didSelect header: String, in section: Int)
}

class EditorHeaderSectionController: ListSectionController {
    
    private var sectionModel: EditorHeaderSectionModel!
    private let cellTemplate = EditorHeaderCollectionCell()
    
    weak var delegate: EditorHeaderSectionControllerDelegate?
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return configure(cell: cellTemplate).sizeThatFits(collectionContext!.containerSize)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeue(of: EditorHeaderCollectionCell.self, for: self, at: index)
    
        return configure(cell: cell)
    }
    
    private func configure(cell: EditorHeaderCollectionCell) -> EditorHeaderCollectionCell {
        cell.titleLabel.text = sectionModel.title.capitalized
        cell.titleLabel.textColor = sectionModel.isSelected ? UIColor(libraryNamed: "stickerFaceTextPrimary") : UIColor(libraryNamed: "stickerFaceTextSecondary")
        cell.selectedIndicatorView.isHidden = !sectionModel.isSelected
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        precondition(object is EditorHeaderSectionModel)
        sectionModel = object as? EditorHeaderSectionModel
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        
        delegate?.editorHeaderSectionController(self, didSelect: sectionModel.title, in: section)
    }
    
}
