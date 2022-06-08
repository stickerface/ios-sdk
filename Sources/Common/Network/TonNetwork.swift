import Foundation
import Alamofire

public class TonNetwork {
        
    static func loginClient(url: URL) {
        var path = url.absoluteString
        path.removeLast()
        
        AF.request(path, method: .get).response { responseData in
            if let data = responseData.data {
                do {
                    let login = try JSONDecoder().decode(TonLoginModel.self, from: data)
                    
                    let id = login.clientId ?? ""
                    let address = login.payload?.first?.address ?? ""
                    let client = TonClient(clientId: id, address: address)
                    
                    UserSettings.tonClient = client
                    
                    TonNetwork.updateBalance()
                } catch {
                    print(error)
                }
            } else {
                print(responseData)
            }
        }
    }
    
    static func updateBalance() {
        guard let address = UserSettings.tonClient?.address else { return }
        let path = "https://beta.stickerface.io/api/tonkeeper/balance?wallet=\(address)"
        
        AF.request(path, method: .get).response { responseData in
            if let data = responseData.data {
                do {
                    let balance = try JSONDecoder().decode(TonBalance.self, from: data)
                    
                    var client = UserSettings.tonClient
                    client?.balance = balance.balance
                    client?.usd = balance.usd
                    
                    UserSettings.tonClient = client
                } catch {
                    print(error)
                }
            } else {
                print(responseData)
            }
            
            NotificationCenter.default.post(name: .tonClientDidUpdate, object: nil)
        }
    }
    
    public static func authRequest() {
        let path = "https://app.tonkeeper.com/ton-login/stickerface.io/api/tonkeeper/authRequest"
        
        if let url = URL(string: path) {
            UIApplication.shared.open(url)
        }
    }
    
}
