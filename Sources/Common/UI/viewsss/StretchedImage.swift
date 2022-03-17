import UIKit

enum StretchedImage: String {
    
    case imMessageBubble
    case gameListFooterBackground
    case gameListPlaceholder
    case voiceIndicatorViewCircle

    var image: UIImage? {
        let cache = Self.bubbleImageCache

        if let cachedImage = cache.object(forKey: imageCacheKey as NSString) {
            return cachedImage
        }
        
        guard let image = UIImage(libraryNamed: imageName) else {
            return nil
        }
        
        let stretchedImage = stretch(image)
        cache.setObject(stretchedImage, forKey: imageCacheKey as NSString)
        
        return stretchedImage
    }
    
    private static let bubbleImageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.name = "StretchedImageCache"
        
        return cache
    }()
    
    private var imageCacheKey: String {
        return rawValue
    }

    private var imageName: String {
        return rawValue.prefix(1).capitalized + rawValue.dropFirst()
    }

    private func stretch(_ image: UIImage) -> UIImage {
        let center = CGPoint(x: image.size.width / 2, y: image.size.height / 2)
        let capInsets = UIEdgeInsets(top: center.y, left: center.x, bottom: center.y, right: center.x)
        
        return image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
    
}
