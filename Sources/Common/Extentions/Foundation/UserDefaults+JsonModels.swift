import Foundation

extension UserDefaults {

    /// Set Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func set<T: Codable>(object: T?, forKey: String) throws {
        if let object = object {
            let jsonData = try JSONEncoder().encode(object)
            set(jsonData, forKey: forKey)
        } else {
            set(nil, forKey: forKey)
        }
    }

    /// Get Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func get<T: Codable>(objectType: T.Type, forKey: String) throws -> T {
        guard let result = value(forKey: forKey) as? Data else {
            throw NSError(domain: "no value", code: -1)
        }

        return try JSONDecoder().decode(objectType, from: result)
    }
    
}
