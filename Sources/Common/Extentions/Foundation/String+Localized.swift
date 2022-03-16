import Foundation

extension String {
    
    var libraryLocalized: String {
        return NSLocalizedString(self, bundle: Bundle.resourceBundle, comment: "")
    }
    
    func libraryLocalized(_ arguments: CVarArg...) -> String {
        return String(format: self.libraryLocalized, arguments: arguments)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
    
}
