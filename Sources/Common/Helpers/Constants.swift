import Foundation

public enum Constants {

    // MARK: - API
    public static var apiUrl: String { (SFDefaults.isDev ? devUrl : prodUrl) + "api" }
    public static let prodUrl = "https://stickerface.io/"
    public static let devUrl = "https://beta.stickerface.io/"
    
    // MARK: - Render
    public static var renderUrl: String { (SFDefaults.isDev ? devUrl : prodUrl) + "render2.html" }
}
