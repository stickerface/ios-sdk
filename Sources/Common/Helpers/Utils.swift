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
    
    static func safeArea() -> UIEdgeInsets {
        if let safeArea = appDelegate()?.window??.safeAreaInsets {
            return safeArea
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    static func safeAreaVertical() -> CGFloat {
        let safeArea = safeArea()
        return safeArea.top + safeArea.bottom
    }
}
