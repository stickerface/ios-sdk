import UIKit
import IGListDiffKit

class StickerFaceMainMint: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return String(describing: self) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return object is StickerFaceMainMint
    }
}
