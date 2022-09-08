public enum Stickers: Int {
    case none = 0
    case nervous = 2
    case ok = 4
    case veryCrying = 16
    case hi = 20
    case sticker21 = 21
    case closedEyes = 25
    case drink = 28
    case crying = 18
    case sticker14 = 14
    case zzz = 26
    case sticker27 = 27
    
    public var stringValue: String {
        return "s\(self.rawValue);"
    }
}
