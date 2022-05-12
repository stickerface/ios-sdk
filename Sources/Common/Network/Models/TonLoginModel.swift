import Foundation

struct TonLoginModel: Codable {
    let clientId: String?
    let payload: [TonLoginPayload]?
}

struct TonLoginPayload: Codable {
    let type: String?
    let address: String?
}

struct TonBalance: Codable {
    let balance: Double
    let usd: Double
}
