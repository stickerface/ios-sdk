import UIKit
import IGListKit

protocol StickerFaceMainMintSectionDelegate: AnyObject {
    func stickerFaceMainMintNeedAllLayers() -> String
}

class StickerFaceMainMintSectionController: ListSectionController {

    weak var delegate: StickerFaceMainMintSectionDelegate?
    
    override init() {
        super.init()
        
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return StickerFaceMainMintCell.cellSize(containerSize: collectionContext!.containerSize)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeue(of: StickerFaceMainMintCell.self, for: self, at: index)
        
        let layers = delegate?.stickerFaceMainMintNeedAllLayers() ?? ""
        ImageLoader.setImage(layers: layers, imgView: cell.avatarImageView)
        
        return cell
    }
    
}
