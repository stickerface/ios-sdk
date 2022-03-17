import IGListKit

public extension ListCollectionContext {
    
    func dequeue<T: AnyObject>(of type: T.Type, for sectionController: ListSectionController, at index: Int) -> T {
        return dequeueReusableCell(of: type, for: sectionController, at: index) as! T
    }
    
    func dequeue<T: AnyObject>(ofKind: String, for sectionController: ListSectionController, of type: T.Type, at index: Int) -> T {
        return dequeueReusableSupplementaryView(ofKind: ofKind, for: sectionController, class: type, at: index) as! T
    }
    
}
