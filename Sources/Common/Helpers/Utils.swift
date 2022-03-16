import UIKit
import CoreMedia
import AVFoundation
import CoreData

class Utils {
    static func getRootViewController() -> UIViewController? {
        return appDelegate()?.window??.rootViewController
    }
    
    static func getTopViewController() -> UIViewController? {
        return getRootNavigationController()?.topViewController
    }

    static func getRootNavigationController() -> UINavigationController? {
        return Utils.getRootViewController() as? UINavigationController
    }
    
    static func appDelegate() -> UIApplicationDelegate? {
        return UIApplication.shared.delegate
    }
}
