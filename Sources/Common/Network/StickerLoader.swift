import UIKit
import Kingfisher
import WebKit

public enum StickerLoadSource {
    case network, render
}

public class StickerLoader: NSObject {
    
    public static var shared: StickerLoader = {
        return StickerLoader()
    }()
    
    public static let defaultLayers = Layers.man
    public static let defaultWomanLayers = Layers.woman
    public static let avatarPath = "\(Constants.apiPath)/png/"
    public static let sectionPath = "\(Constants.apiPath)/section/png/"
    public let renderWebView: WKWebView = .init()
        
    private let decodingQueue: DispatchQueue = .init(label: "\(Bundle.main.bundleIdentifier!).decodingQueue")
    private var requestId: Int = 0
    private var isRendering: Bool = false
    private var isRenderReady: Bool = false
    private var layersForRender: [RenderLayer] = []
    private var reRenderTimer = Timer()
    
    override init() {
        super.init()
        
        DataCache.instance.maxDiskCacheSize = 1024 * 1024 * 100 // 100 mb
        
        let handler = AvatarRenderResponseHandler()
        handler.delegate = self
        
        renderWebView.navigationDelegate = self
        renderWebView.load(URLRequest(url: URL(string: Constants.renderUrl)!))
        renderWebView.configuration.userContentController.add(handler, name: handler.name)
    }
    
    @discardableResult
    public static func loadSticker(
        into imgView: UIImageView,
        with layers: String = StickerLoader.defaultLayers,
        stickerType: StickerType = .avatar,
        outlined: Bool = false,
        size: CGFloat = UIScreen.main.bounds.width,
        placeholderStyle: PlaceholderStyle = .dark,
        placeholderImage: UIImage? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) -> DownloadTask? {
        
        let options: KingfisherOptionsInfo = [
            .loadDiskFileSynchronously,
            .transition(.fade(0.2)),
        ]
        
        imgView.tintColor = placeholderStyle == .dark ? UIColor.black.withAlphaComponent(0.06) : UIColor.white.withAlphaComponent(0.24)
        
        let placeholder = placeholderImage ?? UIImage(libraryNamed: "placeholder_sticker_200")
        let path = "\(Constants.apiPath)/\(stickerType.rawValue)/" + layers + "?size=" + String(describing: size) + "&outline=\(outlined)"
        let stickerURL = URL(string: path)
        
        return imgView.kf.setImage(with: stickerURL, placeholder: placeholder, options: options, completionHandler: completionHandler)
    }
    
    @discardableResult
    public func loadImage(url: String, completion: @escaping (UIImage) -> ()) -> URLSessionDataTask? {
        if let image = DataCache.instance.readImage(forKey: url) {
            completion(image)
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: URL(string: url)!) { data, response, error in
                if error == nil, let data = data, let image = UIImage(data: data) {
                    DataCache.instance.write(image: image, forKey: url)
                    
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
    
    public func renderLayer(
        _ layer: String,
        size: CGFloat = 207.0,
        isOutlined: Bool = false,
        loadSource: StickerLoadSource = .render,
        completionHandler: @escaping ImageAction
    ) {
        let id = getNextRequestId()
        let renderLayer = RenderLayer(
            id: id,
            size: size,
            layer: layer,
            isOutlined: isOutlined,
            completion: completionHandler
        )
        
        if let image = DataCache.instance.readImage(forKey: layer) {
            completionHandler(image)
        } else {
            layersForRender.append(renderLayer)
            renderIfNeeded()
        }
    }
    
    public func preloadLayers(_ layers: [String]) {
        let renderLayer = RenderLayer(preload: layers)
        layersForRender.insert(renderLayer, at: 0)
        renderIfNeeded()
    }
    
    public func clearRenderQueue() {
        isRendering = false
        isRenderReady = false
        layersForRender.removeAll()
        renderWebView.reload()
    }
    
    // MARK: - Private methods
    
    private func getNextRequestId() -> Int {
        let current = requestId
        requestId = (current + 1) % Int.max
        
        return current
    }
    
    var needToRerender = false
    
    private func renderIfNeeded() {
        guard let layer = layersForRender.first,
              isRenderReady,
              !isRendering
        else { return }
        
        isRendering = true
                
        reRenderTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            print("=== INFO rerender")
            self.isRendering = false
            self.renderIfNeeded()
        }
        
        renderWebView.evaluateJavaScript(layer.renderString) { anyO, error in
            if let error = error {
                print("=== error", error)
            }
            
            if layer.id == -1 {
                guard let index = self.layersForRender.firstIndex(where: { $0.id == -1 }) else { return }
                self.isRendering = false
                self.reRenderTimer.invalidate()
                self.layersForRender.remove(at: index)
                self.renderIfNeeded()
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension StickerLoader: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
            guard
                let data = Data(base64Encoded: base64),
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    self.isRendering = false
                    self.renderIfNeeded()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                if let index = self.layersForRender.firstIndex(where: { $0.id == id }) {
                    DataCache.instance.write(image: image, forKey: self.layersForRender[index].layer)
                    self.layersForRender.remove(at: index).completion(image)
                }
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
        let size: CGFloat
        let layer: String
        let isOutlined: Bool
        let completion: ImageAction
        let renderString: String
        
        init(id: Int, size: CGFloat, layer: String, isOutlined: Bool, completion: @escaping ImageAction) {
            self.id = id
            self.size = size
            self.layer = layer
            self.isOutlined = isOutlined
            self.completion = completion
            
            renderString = "renderPNG(\"\(layer)\", \(id), \(size * UIScreen.main.scale), {partial: true, outline:\(isOutlined)})"
        }
        
        init(preload layers: [String]) {
            id = -1
            size = -1
            layer = ""
            isOutlined = false
            completion = { _ in }
            
            let preloadLayers = layers.joined(separator: ";")
            renderString = "preloadLayers(\"\(preloadLayers)\")"
        }
    }
}
