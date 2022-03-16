import UIKit

extension UIImage {
    
    convenience init?(libraryNamed named: String) {
        self.init(named: named, in: Bundle.resourceBundle, with: nil)
    }
    
}
