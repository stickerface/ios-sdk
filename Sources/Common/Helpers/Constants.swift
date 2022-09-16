import Foundation

public enum Constants {

    // MARK: - API
    public static var apiPath: String { (SFDefaults.isDev ? devPath : prodPath) + "api" }
    public static var tonApiPath: String { SFDefaults.isDev ? devTonPath : prodTonPath }
    public static let prodPath = "https://stickerface.io/"
    public static let devPath = "https://beta.stickerface.io/"
    public static let prodTonPath = "https://tonapi.io/v1"
    public static let devTonPath = "https://testnet.tonapi.io/v1"
    
    // MARK: - Render
    public static var renderUrl: String { (SFDefaults.isDev ? devPath : prodPath) + "render2.html" }
}
