import Foundation

extension Bundle {
    
    public static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: StickerFaceFonts.self)

        guard let resourceBundleURL = myBundle.url(
            forResource: "StickerFaceSDK", withExtension: "bundle")
            else { fatalError("StickerFaceSDK.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access StickerFaceSDK.bundle!") }

        return resourceBundle
    }()
    
}
