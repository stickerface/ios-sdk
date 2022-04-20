import UIKit
import IGListKit

protocol StickerFaceMainStoreSectionDelegate: AnyObject {
    func stickerFaceMainStoreSection(needLayers withLayers: [String], color: String?) -> String
}

class StickerFaceMainStoreSectionController: ListSectionController {
    
    weak var delegate: StickerFaceMainStoreSectionDelegate?
    
    override init() {
        super.init()
        
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return StickerFaceMainStoreCell.cellSize(containerSize: collectionContext!.containerSize)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeue(of: StickerFaceMainStoreCell.self, for: self, at: index)
        
        var frontLayers = delegate?.stickerFaceMainStoreSection(needLayers: "291", color: "3214")
        
        ImageLoader.setAvatar(with: , for: cell.nftStoreView.frontAvatarImageView, side: 150, cornerRadius: 0)
        
        return cell
    }
    
}
