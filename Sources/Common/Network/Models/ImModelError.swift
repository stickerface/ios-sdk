import UIKit

enum ApiErrorCode: String {
    case unknown
    case decode
    case token
}

//struct ImModelError: Error, CustomDebugStringConvertible {
//
//    let err: ErrorResponse
//
//    func message() -> String {
//        switch err {
//        case .error( _, let data?, _):
//            do {
//                let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
//                print("json error", json)
//                if let code = json["code"] as? String, code == "token" {
//                    return "Session lost"
//                } else {
//                    return json["desc"] as! String
//                }
//            } catch {
//                return "Server error"
//            }
//        default:
//            return "Server error"
//        }
//    }
//
//    public var code: String {
//        get {
//            switch err {
//            case .error( _, let data?, _):
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
//                    if let code = json["code"] as? String, code == "token" {
//                        return ApiErrorCode.token.rawValue
//                    } else {
//                        return json["code"] as! String
//                    }
//                } catch {
//                    return ApiErrorCode.unknown.rawValue
//                }
//            default:
//                return ApiErrorCode.unknown.rawValue
//            }
//        }
//    }
//
//    var localizedDescription: String {
//        return message()
//    }
//
//    var debugDescription: String {
//        return message()
//    }
//    
//}
