import Foundation

public struct TonClient: Codable {
    public let clientId: String
    public let address: String
    public var balance: Double
    public var usd: Double
    
    init(clientId: String, address: String, balance: Double = 0.0, usd: Double = 0.0) {
        self.clientId = clientId
        self.address = address
        self.balance = balance
        self.usd = usd
    }
}
