import Foundation
import Alamofire

class TonLogin {
    
    init() { }
    
    func loginClient(url: URL) {
        var path = url.absoluteString
        path.removeLast()
        let newUrl = URL(string: path)!
        
        AF.request(newUrl, method: .get).response { responseData in
            if let data = responseData.data {
                do {
                    let login = try JSONDecoder().decode(TonLoginModel.self, from: data)
                                        
                    let id = login.clientId
                    let address = login.payload?.first?.address
                    let client = TonClient(clientId: id, address: address)
                    
                    print("=== clinet", client)
                    
                    UserSettings.tonClient = client
                    
                    NotificationCenter.default.post(name: .tonClientDidLoad, object: nil)
                } catch {
                    print(error)
                }
            } else {
                print(responseData)
            }
        }
    }
    
}
