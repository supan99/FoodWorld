//
//  UIColor+Extension.swift


import Foundation
import UIKit

extension UIColor {
    class func colorFromHex(hex: Int) -> UIColor { return UIColor(red: (CGFloat((hex & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((hex & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(hex & 0xFF)) / 255.0, alpha: 1.0)
    }
    
    static var black                    : UIColor { UIColor.colorFromHex(hex: 0x000000)}
    static var themePink                : UIColor { UIColor.colorFromHex(hex: 0xA00D6A)}
    static var themePlaceHolder         : UIColor { UIColor.colorFromHex(hex: 0xC8C8C8)}
    static var themePurple              : UIColor { UIColor.colorFromHex(hex: 0x2C2053)}
    static var colorLine                : UIColor { UIColor.colorFromHex(hex: 0xDFDFDF)}
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.black
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
