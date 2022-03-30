import UIKit
import IGListDiffKit

class StickerFaceMainSticker {
    
    let layers: String
    
    init(layers: String) {
        self.layers = layers
    }
    
}

extension StickerFaceMainSticker: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return layers as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Self else {
            return false
        }
        
        return object.layers == layers
    }
}
