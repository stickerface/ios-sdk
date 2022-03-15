import UIKit

public class Palette {

    public enum Fonts {
        public static let regular = UIFont(name: "Montserrat-Regular", size: 16)!
        public static let semiBold = UIFont(name: "Montserrat-SemiBold", size: 16)!
        public static let bold = UIFont(name: "Montserrat-Bold", size: 16)!
        public static let medium = UIFont(name: "Montserrat-Medium", size: 16)!
    }

    public static let font = Fonts.regular
    public static let fontSemiBold = Fonts.semiBold
    public static let fontBold = Fonts.bold
    public static let fontMedium = Fonts.medium
}
