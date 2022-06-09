import Foundation
import Alamofire

class StickerFaceEditorProvider {
    
    func loadEditor(completion: @escaping(Result<Editor, Error>) -> Void) {
//        StickerFaceEditorAPI.editorGet { editor, error in
//            if let editor = editor {
//                completion(.success(editor))
//            } else if let error = error {
//                log.error(ImModelError(err: error).message())
//                completion(.failure(ImModelError(err: error)))
//            } else {
//                completion(.failure(NSError()))
//            }
//        }
        
        let url = "http://stickerface.io/api/v2/editor"
        
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
    
//    func buyProduct(productId: String, price: Int, completion: @escaping(Result<Ok, Error>) -> Void) {
//        ShopAPI.shopBuyProductPost(productInput: ProductInput(productId: productId, price: price)) { ok, error in
//            if let ok = ok {
//                completion(.success(ok))
//            } else if let error = error {
//                log.error(ImModelError(err: error).message())
//                completion(.failure(ImModelError(err: error)))
//            } else {
//                completion(.failure(NSError()))
//            }
//        }
//    }
    
//    func getUserProducts(completion: @escaping(Result<[String], Error>) -> Void) {
//        ShopAPI.shopUserProductsGet { listUsersProducts, error in
//            if let listUsersProducts = listUsersProducts {
//                completion(.success(listUsersProducts.items))
//            } else if let error = error {
//                log.error(ImModelError(err: error).message())
//                completion(.failure(ImModelError(err: error)))
//            } else {
//                completion(.failure(NSError()))
//            }
//        }
//    }
    
}
