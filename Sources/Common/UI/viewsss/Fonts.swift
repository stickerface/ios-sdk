import Foundation
import CoreText

public class FaceKitFonts {
    
    public static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: FaceKitFonts.self)

        guard let resourceBundleURL = myBundle.url(
            forResource: "FaceKit", withExtension: "bundle")
            else { fatalError("FaceKit.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access FaceKit.bundle!") }

        return resourceBundle
    }()
    
    public static func setup() {
        registerFont(bundle: resourceBundle, fontName: "MontserratBold", fontExtension: "ttf")
        registerFont(bundle: resourceBundle, fontName: "MontserratMedium", fontExtension: "ttf")
        registerFont(bundle: resourceBundle, fontName: "MontserratRegular", fontExtension: "ttf")
        registerFont(bundle: resourceBundle, fontName: "MontserratSemiBold", fontExtension: "ttf")
    }
    
    private static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            fatalError("Couldn't find font \(fontName)")
        }

        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            fatalError("Couldn't load data from the font \(fontName)")
        }

        guard let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            print("Error registering font: maybe it was already registered.")
            return false
        }

        return true
    }
    
}
