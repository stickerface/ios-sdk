import UIKit

extension UIColor {
    
    convenience init?(libraryNamed named: String) {
        self.init(named: named, in: Bundle.resourceBundle, compatibleWith: nil)
    }
    
}
