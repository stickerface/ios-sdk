import Foundation
import Alamofire

protocol GenerateAvatarProviderDelegate: AnyObject {
    func generateAvatarProvider(didSuccessWith response: GenerateAvatarResponse)
    func generateAvatarProvider(didFailWith error: Error)
}

struct GenerateAvatarResponse: Codable {
    let model: String
    let woman: Int
    let stickers: [Int]
}

class GenerateAvatarProvider {
    
    weak var delegate: GenerateAvatarProviderDelegate?
    
    func uploadImage(imageData: Data) {
        AF.upload(multipartFormData: {
            $0.append(imageData, withName: "file", fileName: "filename.jpg")
        }, to: "https://stickerface.io/api/process?platform=ios")
        .responseDecodable(of: GenerateAvatarResponse.self) { [weak self] response in
            switch response.result {
            case .success(let object):
                self?.delegate?.generateAvatarProvider(didSuccessWith: object)
            case .failure(let error):
                self?.delegate?.generateAvatarProvider(didFailWith: error)
            }
        }
    }
    
}
