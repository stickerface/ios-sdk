import UIKit
import IGListKit

protocol StickerFaceMainStoreSectionDelegate: AnyObject {
    func stickerFaceMainStore(needAllLayers withLayers: [(layer: String, color: String?)]) -> String
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
        
        let frontReplaceLayers = [(layer: "291", color: "3214"), (layer: "146", color: nil)]
        let frontLayers = delegate?.stickerFaceMainStore(needAllLayers: frontReplaceLayers)
        
        if frontLayers != "" {
            StickerLoader.loadSticker(into: cell.nftStoreView.frontAvatarImageView, with: frontLayers ?? "")
        }
        
        let backReplaceLayers = [
            (layer: "310", color: "3210"),
            (layer: "255", color: nil),
            (layer: "238", color: nil)
        ]
        let backLayers = delegate?.stickerFaceMainStore(needAllLayers: backReplaceLayers)
        
        if backLayers != "" {
            StickerLoader.loadSticker(into: cell.nftStoreView.backAvatarImageView, with: backLayers ?? "")
        }
        
        return cell
    }
    
}
