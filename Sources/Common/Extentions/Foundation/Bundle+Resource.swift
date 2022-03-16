import Foundation

extension Bundle {
    
    public static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: StikerFaceFonts.self)

        guard let resourceBundleURL = myBundle.url(
            forResource: "StikerFace", withExtension: "bundle")
            else { fatalError("StikerFace.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access StikerFace.bundle!") }

        return resourceBundle
    }()
    
}
