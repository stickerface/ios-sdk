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
    
    func loadWardrobe(onSale: Bool, offset: Int, completion: @escaping(Result<WalletNft, Error>) -> Void) {
        guard let owner = SFDefaults.tonClient?.address,
              let collection = SFDefaults.wearablesCollection
        else {
            completion(.failure(NSError(domain: "no address or collection", code: -1)))
            return
        }
        
        let path = "/nft/searchItems"
        let url = Constants.tonApiPath + path
        let parameters: Parameters = [
            "owner": owner,
            "collection": collection,
            "include_on_sale": onSale,
            "limit": 1000,
            "offset": offset
        ]

        AF.request(url, method: .get, parameters: parameters).response { responseData in
            if let data = responseData.data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let object = try decoder.decode(WalletNft.self, from: data)
                    completion(.success(object))
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
