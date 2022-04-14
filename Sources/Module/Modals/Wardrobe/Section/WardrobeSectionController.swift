import Foundation
import IGListKit

protocol WardrobeSectionControllerDelegate: AnyObject {
    func wardrobeSectionController(_ controller: WardrobeSectionController, didSelect layer: String)
}

class WardrobeSectionController: ListSectionController {
    
    private var sectionModel: WardrobeSectionModel!
    private let cellTemplate = EditorLayerCollectionCell()
    
    weak var delegate: WardrobeSectionControllerDelegate?
    
    override init() {
        super.init()
        
        inset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 50.0, right: 16.0)
        minimumLineSpacing = 12.0
        minimumInteritemSpacing = 12.0
    }
    
    override func numberOfItems() -> Int {
        return sectionModel.layers.count
    }
    
    override func didUpdate(to object: Any) {
        precondition(object is WardrobeSectionModel)
        sectionModel = object as? WardrobeSectionModel
    }
    
    // TODO: Need fit size  
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 16 - 12 - 16)/2, height: 188)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeue(of: EditorLayerCollectionCell.self, for: self, at: index)
        cell.layerType = .NFT
        
        let layer = sectionModel.layers[index]
        let imageSide = 172
        let url = "https://stickerface.io/api/section/png/\(layer)?size=\(imageSide)"
                
        ImageLoader.setImage(url: url, imgView: cell.layerImageView) { result in
            switch result {
            case .success: cell.contentView.hideSkeleton()
            case .failure: break
            }
        }
                
        cell.titleLabel.text = "Checkered shirt"
        cell.noneImageView.isHidden = true
        
        cell.setSelected(sectionModel.selectedLayer == layer)
        cell.setPrice(0, isPaid: true)
        
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        
        let layer = sectionModel.layers[index]
        delegate?.wardrobeSectionController(self, didSelect: layer)
    }
    
}

