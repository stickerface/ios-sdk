import UIKit
import Kingfisher

class ImageLoader: NSObject {

    static var shared: ImageLoader = {
       return ImageLoader()
    }()
    
    static let defaultLayers = "6;16;253;265;28;3000;12;224;160;159;1;69;22;250;90;81;13;100;3040;271;3220;70;317;"

    var cache = NSCache<NSString, UIImage>()
    
    enum PlaceholderStyle {
        case light
        case dark
    }

    @discardableResult
    static func setImage(layers: String, imgView: UIImageView, outlined: Bool = false, size: CGFloat = 600, placeholderStyle: PlaceholderStyle = .dark, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {
        
        let options: KingfisherOptionsInfo = [
            .loadDiskFileSynchronously,
            .transition(.fade(0.2)),
        ]

        if placeholderStyle == .dark {
            imgView.tintColor = UIColor.black.withAlphaComponent(0.06)
        } else if placeholderStyle == .light {
            imgView.tintColor = UIColor.white.withAlphaComponent(0.24)
        }
        
        let placeholder = UIImage(libraryNamed: "placeholder_sticker_200")?.withRenderingMode(.alwaysTemplate)
        let url = URL(string: "http://sticker.face.cat/api/png/" + layers + "?size=" + String(describing: size * UIScreen.main.scale) + "&outline=\(outlined)")
        
        return imgView.kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func setAvatar(with layers: String? = defaultLayers, url: String? = nil, imageUrl: String? = nil, outlined: Bool = false, backgroundColor: UIColor? = nil, options: KingfisherOptionsInfo? = nil, for imageView: UIImageView, placeholderImage: UIImage? = nil, side: CGFloat, cornerRadius: CGFloat) -> DownloadTask? {
        let avatarURL: URL?
        
        if let url = url {
            avatarURL = URL(string: url)
        } else if let imageUrl = imageUrl, !imageUrl.isEmpty {
            avatarURL = URL(string: imageUrl)
        } else if let layers = layers {
            avatarURL = URL(string: "http://sticker.face.cat/api/png/" + layers + "?size=" + String(Int(side * UIScreen.main.scale)) + "&outline=\(outlined)")
        } else {
            preconditionFailure("Unknown avatar type")
        }
        
        let placeholder = placeholderImage ?? UIImage(libraryNamed: "placeholder_sticker_200")
        let processor = RoundCornerImageProcessor(cornerRadius: cornerRadius * UIScreen.main.scale,
                                                  targetSize: CGSize(side: side * UIScreen.main.scale),
                                                  backgroundColor: .clear)
            .append(another: RoundCornerImageProcessor(cornerRadius: cornerRadius * UIScreen.main.scale))
        
        imageView.tintColor = UIColor.black.withAlphaComponent(0.06)
        
        var imageOptions: KingfisherOptionsInfo = [
            .transition(.fade(0.2)),
            .scaleFactor(UIScreen.main.scale),
            .processor(processor)
        ]
        
        if let options = options {
            imageOptions += options
        }
        
        return imageView.kf.setImage(with: avatarURL, placeholder: placeholder, options: imageOptions)
    }
    
    @discardableResult
    static func setImage(url: String?, imgView: UIImageView, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {
        guard let url = url else {
            return nil
        }
        
        let options: KingfisherOptionsInfo = [
            .loadDiskFileSynchronously,
            .transition(.fade(0.2)),
        ]

        return imgView.kf.setImage(with: URL(string: url), options: options, completionHandler: completionHandler)
    }

    @discardableResult
    func loadImage(url: NSString, completion: @escaping (UIImage) -> ()) -> URLSessionDataTask? {

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

extension UIImage {
    func blurredImage(with context: CIContext, radius: CGFloat, atRect: CGRect) -> UIImage? {
        guard let ciImg = CIImage(image: self) else { return nil }

        let cropedCiImg = ciImg.cropped(to: atRect)
        let blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(cropedCiImg, forKey: kCIInputImageKey)
        blur?.setValue(radius, forKey: kCIInputRadiusKey)
        
        if let ciImgWithBlurredRect = blur?.outputImage?.composited(over: ciImg),
           let outputImg = context.createCGImage(ciImgWithBlurredRect, from: ciImgWithBlurredRect.extent) {
            return UIImage(cgImage: outputImg)
        }
        return nil
    }
}
