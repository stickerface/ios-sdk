import Foundation
import Alamofire

class TonNetwork {
    
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
                    
                    UserSettings.tonClient = client
                    
                    self.updateBalance()
                    NotificationCenter.default.post(name: .tonClientDidLoad, object: nil)
                } catch {
                    print(error)
                }
            } else {
                print(responseData)
            }
        }
    }
    
    func updateBalance() {
        guard let address = UserSettings.tonClient?.address else { return }
        
        let path = "https://stickerface.io/api/tonkeeper/balance?wallet=\(address)"
        let url = URL(string: path)!
        
        AF.request(url, method: .get).response { responseData in
            if let data = responseData.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    
                    print("=== json", json)
                } catch {
                    print(error)
                }
            } else {
                print(responseData)
            }
        }
    }
    
}
