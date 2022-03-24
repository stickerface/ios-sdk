import Foundation
import Alamofire

// TODO: need api
class StickerFaceEditorAPI {
    
//    class func editorGet(completion: @escaping ((_ data: Editor?,_ error: ErrorResponse?) -> Void)) {
//        editorGetWithRequestBuilder().execute { (response, error) -> Void in
//            completion(response?.body, error)
//        }
//    }
//    
//    class func editorGetWithRequestBuilder() -> RequestBuilder<Editor> {
//        let basePath = "http://stickerface.io/"
//        let path = "api/editor"
//        let URLString = basePath + path
//        let parameters: [String:Any]? = nil
//        
//        let requestBuilder: RequestBuilder<Editor>.Type = FaceCatAPIAPI.requestBuilderFactory.getBuilder()
//
//        return requestBuilder.init(method: "GET", URLString: URLString, parameters: parameters, isBody: false)
//    }
    
}

struct Editor: Codable {
    let prices: [String: Int]
    let sections: [EditorSection]
}

struct EditorSection: Codable {
    let name: String
    let subsections: [EditorSubsection]
}

struct EditorSubsection: Codable {
    let name: String
    let layers: [String]?
    let colors: [EditorColor]?
}

struct EditorColor: Codable {
    let id: Int
    let hash: String
}
