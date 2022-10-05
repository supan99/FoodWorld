//
//  UILabel+Extension.swift


import Foundation
import UIKit
extension UILabel {
    func setAttributedString(_ arrStr : [String] , attributes : [[NSAttributedString.Key : Any]]) {
        let str = self.text!
        
        let attributedString = NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.font: self.font as Any])
        
        for index in 0...arrStr.count - 1 {
            
            let attr = attributes[index]
            attributedString.addAttributes(attr, range: (str as NSString).range(of: arrStr[index]))
        }
        
        self.attributedText = attributedString
    }
}
