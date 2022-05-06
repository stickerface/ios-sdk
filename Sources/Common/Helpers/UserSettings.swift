import Foundation

@objc public class UserSettings: NSObject {
    
    public enum Gender: String {
        case male
        case female
    }
    
    public static let defaults = UserDefaults.standard
    
    public static var layers: String? {
        get {
            return defaults.string(forKey: #function)
        }
        set {
            defaults.set(newValue, forKey: #function)
        }
    }
                
    
    public static var tonBalance: Double? {
        get {
            let tonString = defaults.string(forKey: #function)
            return tonString == nil ? nil : Double(tonString!)
        }
        set {
            defaults.set(newValue?.description, forKey: #function)
        }
    }
    
    public static var gender: Gender {
        get {
            let genderString = defaults.string(forKey: #function) ?? "male"
            return Gender(rawValue: genderString) ?? .male
        }
        set {
            defaults.set(newValue.rawValue, forKey: #function)
        }
    }
    
    public static var wardrobe: [String] {
        get {
            return defaults.stringArray(forKey: #function) ?? []
        }
        set {
            defaults.set(newValue, forKey: #function)
        }
    }
    
    public static var paidBackgrounds: [String] {
        get {
            return defaults.stringArray(forKey: #function) ?? []
        }
        set {
            defaults.set(newValue, forKey: #function)
        }
    }
    
    public static var isOnboardingShown: Bool {
        get {
            return defaults.bool(forKey: #function)
        }
        set {
            defaults.set(newValue, forKey: #function)
        }
    }
    
    public static var tonClient: TonClient? {
        get {
            let data = defaults.data(forKey: #function) ?? Data()
            return try? JSONDecoder().decode(TonClient.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: #function)
        }
    }
}
