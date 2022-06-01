import UIKit

public struct SFAvatar: Codable {
    /// Avatar png image with all layers
    public let avatarImage: Data
    
    /// Avatar png image without background layer
    public let personImage: Data
    
    /// Background layer png image from avatar
    public let backgroundImage: Data
    
    /// Layers from avatar
    public let layers: String
}
