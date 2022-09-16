import UIKit

public class SFAvatar: Codable {
    
    /// Avatar png data
    public let avatarImage: Data?
    
    /// Avatar png data without background layer
    public var personImage: Data?
    
    /// Avatar background layer png data
    public let backgroundImage: Data?
    
    /// Avatar layers
    public let layers: String
    
    /// Avatar layers without background
    public let personLayers: String?
    
    /// Background layer
    public let backgroundLayer: String?
    
    public init(avatarImage: Data?, personImage: Data?, backgroundImage: Data?, layers: String, personLayers: String?, backgroundLayer: String?) {
        self.avatarImage = avatarImage
        self.personImage = personImage
        self.backgroundImage = backgroundImage
        self.layers = layers
        self.personLayers = personLayers
        self.backgroundLayer = backgroundLayer
    }
}

extension SFAvatar: Equatable {
    public static func == (lhs: SFAvatar, rhs: SFAvatar) -> Bool {
        return lhs.avatarImage == rhs.avatarImage
        && lhs.personImage == rhs.personImage
        && lhs.backgroundImage == rhs.backgroundImage
        && lhs.layers == rhs.layers
        && lhs.personLayers == rhs.personLayers
        && lhs.backgroundLayer == rhs.backgroundLayer
    }
}
