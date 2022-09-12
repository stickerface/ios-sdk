import Foundation
import Alamofire

class StickerFaceEditorProvider {
    
    func loadEditor(completion: @escaping(Result<Editor, Error>) -> Void) {
        let url = "\(Constants.apiUrl)/v2/editor"
        
        AF.request(url, method: .get).response { responseData in
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
