import UIKit
import Kingfisher

public class StickerLoader: NSObject {

    public static var shared: StickerLoader = {
       return StickerLoader()
    }()
    
    public static let defaultLayers = "3;34;7;69;14;159;253;250;13;160;100;3040;265;224;1;76;3000;273;3200;81;22;90;28"
    public static let avatarPath = "http://stickerface.io/api/png/"
    public static let sectionPath = "http://stickerface.io/api/section/png/"
    
    var cache = NSCache<NSString, UIImage>()
    
    public enum PlaceholderStyle {
        case light
        case dark
    }
    
    public enum StickerType: String {
        case avatar = "png"
        case section = "section/png"
    }

    @discardableResult
    public static func loadSticker(into imgView: UIImageView, with layers: String = StickerLoader.defaultLayers, stickerType: StickerType = .avatar, outlined: Bool = false, size: CGFloat = UIScreen.main.bounds.width, placeholderStyle: PlaceholderStyle = .dark, placeholderImage: UIImage? = nil, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {
        
        let options: KingfisherOptionsInfo = [
            .loadDiskFileSynchronously,
            .transition(.fade(0.2)),
        ]

        imgView.tintColor = placeholderStyle == .dark ? UIColor.black.withAlphaComponent(0.06) : UIColor.white.withAlphaComponent(0.24)
        
        let placeholder = placeholderImage ?? UIImage(libraryNamed: "placeholder_sticker_200")
        let path = "http://stickerface.io/api/\(stickerType.rawValue)/" + layers + "?size=" + String(describing: size) + "&outline=\(outlined)"
        let stickerURL = URL(string: path)
        
        return imgView.kf.setImage(with: stickerURL, placeholder: placeholder, options: options, completionHandler: completionHandler)
    }

    @discardableResult
    public func loadImage(url: String, completion: @escaping (UIImage) -> ()) -> URLSessionDataTask? {
        let url = url as NSString
        
        if let image = cache.object(forKey: url) {
            completion(image)
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: URL(string: url as String)!) { [weak self] (data, response, error) in
                if error == nil, let data = data, let image = UIImage(data: data) {
                    self?.cache.setObject(image, forKey: url)

                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
            task.resume()

            return task
        }

        return nil
    }
}
