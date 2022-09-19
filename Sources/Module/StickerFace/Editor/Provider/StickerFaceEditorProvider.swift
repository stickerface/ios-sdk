import Foundation
import Alamofire

class StickerFaceEditorProvider {
    
    func loadEditor(completion: @escaping(Result<Editor, Error>) -> Void) {
        let url = "\(Constants.apiPath)/v2/editor"
        
        let parameters: Parameters = [
            "testnet": SFDefaults.isDev ? 1 : 0
        ]
        
        AF.request(url, method: .get, parameters: parameters).response { responseData in
            if let data = responseData.data {
                do {
                    let editor = try JSONDecoder().decode(Editor.self, from: data)
                    completion(.success(editor))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = responseData.error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError()))
            }
        }
    }
    
}
