import Foundation

extension Bundle {
    
    public static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: StickerFaceFonts.self)
        
        guard let resourceBundleURL = myBundle.url(
            forResource: "StickerFace", withExtension: "bundle")
            else { fatalError("StickerFace.bundle not found!") }

        print("===", resourceBundleURL)
        
        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access StickerFace.bundle!") }

        return resourceBundle
    }()
    
}
