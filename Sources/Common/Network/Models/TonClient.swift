import Foundation

public struct TonClient: Codable {
    let clientId: String
    let address: String
    var balance: Float
    var usd: Float
    
    init(clientId: String, address: String, balance: Float = 0.0, usd: Float = 0.0) {
        self.clientId = clientId
        self.address = address
        self.balance = balance
        self.usd = usd
    }
}
