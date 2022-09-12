import Foundation
import IGListDiffKit

class EditorSubsectionSectionModel {
    
    var editorSubsection: EditorSubsection
    var prices: [String: Int]
    var selectedLayer: String?
    var selectedColor: String?
    var newLayersImages: [String: UIImage]?
    var oldLayersImages: [String: UIImage]?
    
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
        
        return object.editorSubsection == editorSubsection
        && object.prices == prices
        && object.selectedLayer == selectedLayer
        && object.selectedColor == selectedColor
        && object.newLayersImages == newLayersImages
        && object.oldLayersImages == oldLayersImages
    }
    
}
