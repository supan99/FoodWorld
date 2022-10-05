//
//  UIStoryBoard+Extension.swift


import Foundation
import UIKit



extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}



extension UIView {
    func viewStyle() {
        self.clipsToBounds = true
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = self.frame.height / 4
    }
    
    @discardableResult func shadow(color: UIColor = UIColor.black, shadowOffset : CGSize = CGSize(width: 1.0, height: 1.0) , shadowOpacity : Float = 0.5) -> Self {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = false
        return self
    }
}
