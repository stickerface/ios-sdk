import Foundation
import IGListDiffKit

class EditorSubsectionSectionModel {
    
    let editorSubsection: EditorSubsection
    var prices: [String: Int]
    var selectedLayer: String?
    var selectedColor: String?
    
    init(editorSubsection: EditorSubsection, prices: [String:Int]) {
        self.editorSubsection = editorSubsection
        self.prices = prices
    }
    
}

// MARK: - ListDiffable
extension EditorSubsectionSectionModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return editorSubsection.name as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Self else {
            return false
        }
        
        return object.editorSubsection.layers == editorSubsection.layers
    }
    
}
