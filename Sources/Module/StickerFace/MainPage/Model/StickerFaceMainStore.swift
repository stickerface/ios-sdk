import UIKit
import IGListDiffKit

class StickerFaceMainStore: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return String(describing: self) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return object is StickerFaceMainStore
    }
}
