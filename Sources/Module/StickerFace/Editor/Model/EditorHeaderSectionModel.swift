import Foundation
import IGListDiffKit

class EditorHeaderSectionModel {
    
    let title: String
    var isSelected = false
    
    init(title: String) {
        self.title = title
    }
    
}

// MARK: - ListDiffable
extension EditorHeaderSectionModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return title as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Self else {
            return false
        }
        
        return object.title == title
        && object.isSelected == isSelected
    }
    
}
