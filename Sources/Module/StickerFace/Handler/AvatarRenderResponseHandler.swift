import Foundation
import WebKit

protocol AvatarRenderResponseHandlerDelegate: AnyObject {
    func onImageReady(base64: String)
}

class AvatarRenderResponseHandler: NSObject, WKScriptMessageHandler {
    
    weak var delegate: AvatarRenderResponseHandlerDelegate?
    
    var name: String {
        return "response"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == name else {
            return
        }
        
        guard let bodyString = message.body as? String, let data = bodyString.data(using: .utf8),
              let bodyJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let body = bodyJSON as? [String: Any] else {
            return
        }
                
        if let base64String = body["data"] as? String {
            delegate?.onImageReady(base64: base64String)
        }
    }
    
}
