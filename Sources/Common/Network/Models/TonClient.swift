import Foundation

public struct TonClient: Codable {
    let clientId: String
    let address: String
    var balance: Double
    var usd: Double
    
    init(clientId: String, address: String, balance: Double = 0.0, usd: Double = 0.0) {
        self.clientId = clientId
        self.address = address
        self.balance = balance
        self.usd = usd
    }
}
