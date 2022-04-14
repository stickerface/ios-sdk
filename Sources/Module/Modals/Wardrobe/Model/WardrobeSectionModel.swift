import Foundation
import IGListDiffKit

class WardrobeSectionModel {
    
    let layers: [String]
    var selectedLayer: String?
    
    init(layers: [String]) {
        self.layers = layers
    }
    
}

// MARK: - ListDiffable
extension WardrobeSectionModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return String(describing: self) as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return object is WardrobeSectionModel
    }
}
