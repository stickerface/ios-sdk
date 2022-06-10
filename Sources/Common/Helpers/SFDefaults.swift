import Foundation

class SFDefaults {
    
    static let prefixName = "stickerface.io."
    
    public enum Gender: String {
        case male
        case female
    }
    
    public static let defaults = UserDefaults.standard
    
    public static var layers: String? {
        get {
            return defaults.string(forKey: SFDefaults.prefixName + #function)
        }
        set {
            defaults.set(newValue, forKey: SFDefaults.prefixName + #function)
        }
    }
                
    
    public static var tonBalance: Double? {
        get {
            let tonString = defaults.string(forKey: SFDefaults.prefixName + #function)
            return tonString == nil ? nil : Double(tonString!)
        }
        set {
            defaults.set(newValue?.description, forKey: SFDefaults.prefixName + #function)
        }
    }
    
    public static var gender: Gender {
        get {
            let genderString = defaults.string(forKey: SFDefaults.prefixName + #function) ?? "male"
            return Gender(rawValue: genderString) ?? .male
        }
        set {
            defaults.set(newValue.rawValue, forKey: SFDefaults.prefixName + #function)
        }
    }
    
    public static var wardrobe: [String] {
        get {
            return defaults.stringArray(forKey: SFDefaults.prefixName + #function) ?? []
        }
        set {
            defaults.set(newValue, forKey: SFDefaults.prefixName + #function)
        }
    }
    
    public static var paidBackgrounds: [String] {
        get {
            return defaults.stringArray(forKey: SFDefaults.prefixName + #function) ?? []
        }
        set {
            defaults.set(newValue, forKey: SFDefaults.prefixName + #function)
        }
    }
    
    public static var isOnboardingShown: Bool {
        get {
            return defaults.bool(forKey: SFDefaults.prefixName + #function)
        }
        set {
            defaults.set(newValue, forKey: SFDefaults.prefixName + #function)
        }
    }
    
    public static var isFirstEdit: Bool  {
        get {
            return defaults.bool(forKey: SFDefaults.prefixName + #function)
        }
        set {
            defaults.set(newValue, forKey: SFDefaults.prefixName + #function)
        }
    }
    
    public static var tonClient: TonClient? {
        get {
            return try? defaults.get(objectType: TonClient.self, forKey: SFDefaults.prefixName + #function)
        }
        set {
            try? defaults.set(object: newValue, forKey: SFDefaults.prefixName + #function)
        }
    }
}
