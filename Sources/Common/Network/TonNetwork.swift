import Foundation
import Alamofire

public class TonNetwork {
        
    static func loginClient(url: URL) {
        var path = url.absoluteString
        path.removeLast()
        
        AF.request(path, method: .get).response { responseData in
            if let data = responseData.data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let login = try decoder.decode(TonLoginModel.self, from: data)
                    
                    let id = login.clientId ?? ""
                    let address = login.payload?.first?.address ?? ""
                    let client = TonClient(clientId: id, address: address)
                    
                    EditorHelper.shared.reloadEditor(for: client.address)
                    TonNetwork.updateBalance(client: client)
                } catch {
                    print(error)
                }
            } else {
                print(responseData)
            }
        }
    }
    
    public static func updateBalance(client: TonClient) {
        var client = client
        let path = "\(Constants.apiPath)/tonkeeper/balance?wallet=\(client.address)&testnet=\(SFDefaults.isDev ? 1 : 0)"
        
        AF.request(path, method: .get).response { responseData in
            if let data = responseData.data {
                do {
                    let balance = try JSONDecoder().decode(TonBalance.self, from: data)
                    
                    client.balance = balance.balance
                    client.usd = balance.usd
                } catch {
                    print(error)
                }
            } else {
                print(responseData)
            }
            
            SFDefaults.tonClient = client
            NotificationCenter.default.post(name: .tonClientDidUpdate, object: client)
        }
    }
    
    public static func authRequest() {
        let path = "https://app.tonkeeper.com/ton-login/stickerface.io/api/tonkeeper/authRequest"
        
        if let url = URL(string: path) {
            UIApplication.shared.open(url)
        }
    }
    
}
