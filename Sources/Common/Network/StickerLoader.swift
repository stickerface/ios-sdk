import UIKit
import Kingfisher
import WebKit

public class StickerLoader: NSObject {
    
    public static var shared: StickerLoader = {
        return StickerLoader()
    }()
    
    public static let defaultLayers = Layers.man
    public static let defaultWomanLayers = Layers.woman
    public static let avatarPath = "http://stickerface.io/api/png/"
    public static let sectionPath = "http://stickerface.io/api/section/png/"
    public let renderWebView: WKWebView = .init()
    
    var cache = NSCache<NSString, UIImage>()
    
    private let decodingQueue: DispatchQueue = .init(label: "\(Bundle.main.bundleIdentifier!).decodingQueue")
    private var requestId: Int = 0
    private var isRendering: Bool = false
    private var isRenderReady: Bool = false
    private var layersForRender: [RenderLayer] = []
    private var reRenderTimer = Timer()
    
    override init() {
        super.init()
        
        let handler = AvatarRenderResponseHandler()
        handler.delegate = self
        
        renderWebView.navigationDelegate = self
        
        renderWebView.load(URLRequest(url: URL(string: "https://stickerface.io/render2.html")!))
        renderWebView.configuration.userContentController.add(handler, name: handler.name)
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
    
    public func renderLayer(_ layer: String, size: Float = 207.0, completionHandler: @escaping ImageAction) {
        let id = getNextRequestId()
        let layer = RenderLayer(id: id, size: size, layer: layer, completion: completionHandler)
        
        print("=== layer created")
        
        layersForRender.append(layer)
        renderIfNeeded()
    }
    
    public func clearRenderQueue() {
        print("=== will clear")
        isRendering = false
        isRenderReady = false
        layersForRender.removeAll()
        renderWebView.load(URLRequest(url: URL(string: "https://stickerface.io/render2.html")!))
    }
    
    // MARK: - Private methods
    
    private func getNextRequestId() -> Int {
        let current = requestId
        requestId = (current + 1) % Int.max
        
        return current
    }
    
    var needToRerender = false
    
    private func renderIfNeeded() {
        guard let layer = layersForRender.first, isRenderReady, !isRendering else {
            return
        }
        
        isRendering = true
        
        print("=== will render")
        
        reRenderTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            print("=== rerender did")
            self.isRendering = false
            self.renderIfNeeded()
        }
        
        renderWebView.evaluateJavaScript(layer.renderString) { anyO, error in
            if let error = error {
                print("=== error", error)
            }
            
            if anyO == nil {
                print("=== any is nil")
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension StickerLoader: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("=== render ready")
        
        isRenderReady = true
        renderIfNeeded()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("=== webView error", error)
    }
}

// MARK: - AvatarRenderResponseHandlerDelegate

extension StickerLoader: AvatarRenderResponseHandlerDelegate {
    func onImageReady(id: Int, base64: String) {
        reRenderTimer.invalidate()
        
        decodingQueue.async {
            print("=== did render")
            guard
                let index = self.layersForRender.firstIndex(where: { $0.id == id }),
                let data = Data(base64Encoded: base64),
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    if self.layersForRender.firstIndex(where: { $0.id == id }) != nil {
                        if let data = Data(base64Encoded: base64) {
                            if UIImage(data: data) == nil {
                                print("=== error no image")
                            }
                        } else {
                            print("=== error no data")
                        }
                    } else {
                        print("=== error no index")
                    }
                    
                    self.isRendering = false
                    self.renderIfNeeded()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                print("=== will completion")
                self.layersForRender.remove(at: index).completion(image)
                self.isRendering = false
                self.renderIfNeeded()
            }
        }
    }
}

extension StickerLoader {
    public typealias ImageAction = (UIImage) -> ()
    
    public enum PlaceholderStyle {
        case light
        case dark
    }
    
    public enum StickerType: String {
        case avatar = "png"
        case section = "section/png"
    }
    
    enum Layers {
        static let man = "69;159;253;250;13;160;100;3040;265;1;76;3000;273;3200;90;28;23;203;11;68;219;83;35;"
        static let woman = "69;159;253;250;160;3040;265;76;3000;273;3200;90;83;0;0;25;133;224;132,134;10;39;15;32;101;"
    }
    
    struct RenderLayer {
        let id: Int
        let size: Float
        let layer: String
        let completion: ImageAction
        
        var renderString: String {
            return "renderPNG(\"\(layer)\", \(id), \(size * Float(UIScreen.main.scale)), {partial: true})"
        }
    }
}
