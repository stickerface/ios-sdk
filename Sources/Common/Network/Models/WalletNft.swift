import Foundation

public struct WalletNft: Codable {
    public let nftItems: [NftItem]?
}

public struct NftItem: Codable {
    public let address: String?
    public let collection: NFTCollection?
    public let collectionAddress: String?
    public let index: Int?
    public let metadata: NFTMetadata?
    public let owner: NFTOwner?
    public let previews: [NFTPreview]?
    public let verified: Bool?
}

public struct NFTCollection: Codable, Equatable {
    public let address: String?
    public let name: String?
    
    public init(address: String?, name: String?) {
        self.address = address
        self.name = name
    }
}

public struct NFTMetadata: Codable {
    public let attributes: [NFTAttribute]?
    public let description: String?
    public let image: String?
    public let name: String?
}

public enum TraitType: String, Codable {
    case layer, layers, section, subsection, special
    case diamondSize = "Diamond Size"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        
        if let userType = TraitType(rawValue: rawString.lowercased()) {
            self = userType
        } else {
            self = TraitType.unknown
        }
    }
}

public struct NFTAttribute: Codable {
    public let traitType: TraitType?
    public let value: String?
    public let layers: String?
    
    enum CodingKeys: String, CodingKey {
        case traitType
        case value
        case layers
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let layers = try? values.decodeIfPresent(String.self, forKey: .layers) {
            traitType = .layers
            value = layers
            self.layers = nil
        } else {
            traitType = try? values.decodeIfPresent(TraitType.self, forKey: .traitType)
            value = try? values.decodeIfPresent(String.self, forKey: .value)
            layers = nil
        }
    }
}

public struct NFTOwner: Codable, Equatable {
    public let address: String?
    public let isScam: Bool?
    
    public init(address: String?, isScam: Bool?) {
        self.address = address
        self.isScam = isScam
    }
}

public struct NFTPreview: Codable {
    public let resolution: String?
    public let url: String?
}
