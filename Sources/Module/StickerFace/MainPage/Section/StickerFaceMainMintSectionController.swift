import UIKit
import IGListKit

class StickerFaceMainMintSectionController: ListSectionController {

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
        
        return cell
    }
    
}
