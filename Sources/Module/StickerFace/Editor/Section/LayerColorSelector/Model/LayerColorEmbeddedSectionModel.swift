import Foundation
import IGListDiffKit

class LayerColorEmbeddedSectionModel {
    
    let color: EditorColor
    var isSelected = false
    
    init(color: EditorColor) {
        self.color = color
    }
    
}

// MARK: - ListDiffable
extension LayerColorEmbeddedSectionModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return String(color.id) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Self else {
            return false
        }
        
        return object.color.id == color.id
    }
    
}
