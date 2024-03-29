import Foundation
import Alamofire

// TODO: need api
class StickerFaceEditorAPI {
        
}

struct Editor: Codable {
    let nft: EditorNFT
    let prices: [String: Int]
    var sections: GenderSections
    let v: Float
}

struct EditorNFT: Codable {
    let avatarCollection: String
    let avatarMintPrice: Int
    let wearablesCollection: String
    
    enum CodingKeys: String, CodingKey {
        case avatarCollection = "avatar_collection"
        case avatarMintPrice = "avatar_mint_price"
        case wearablesCollection = "wearables_collection"
    }
}

struct GenderSections: Codable {
    var man: [EditorSection]
    var woman: [EditorSection]
}

struct EditorSection: Codable {
    let name: String
    var subsections: [EditorSubsection]
}

struct EditorSubsection: Codable, Equatable {
    let name: String
    var layers: [String]?
    let colors: [EditorColor]?
}

struct EditorColor: Codable, Equatable {
    let id: Int
    let hash: String
}

class EditorSectionModel {
    let name: String
    let sections: [EditorSubsectionSectionModel]
    
    init(name: String, sections: [EditorSubsectionSectionModel]) {
        self.name = name
        self.sections = sections
    }
}
