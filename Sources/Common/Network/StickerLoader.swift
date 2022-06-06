import UIKit
import Kingfisher

public class StickerLoader: NSObject {

    static var shared: StickerLoader = {
       return StickerLoader()
    }()
    
    static let defaultLayers = "12;3200;1;3040;3000;159;28;160;100;15;253;265;13;89;273;224;250;69;81;3;22;7;75;"
    static let avatarPath = "http://stickerface.io/api/png/"
    static let sectionPath = "http://stickerface.io/api/section/png/"
    
    var cache = NSCache<NSString, UIImage>()
    
    enum PlaceholderStyle {
        case light
        case dark
    }
    
    enum StickerType: String {
        case avatar = "png"
        case section = "section/png"
    }

    @discardableResult
    static func loadSticker(into imgView: UIImageView, with layers: String = StickerLoader.defaultLayers, stickerType: StickerType = .avatar, outlined: Bool = false, size: CGFloat = UIScreen.main.bounds.width, placeholderStyle: PlaceholderStyle = .dark, placeholderImage: UIImage? = nil, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {
        
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
    func loadImage(url: String, completion: @escaping (UIImage) -> ()) -> URLSessionDataTask? {
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
