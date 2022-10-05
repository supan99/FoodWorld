////
//  UIImageView+Extensions.swift

import Foundation
@_exported import SDWebImage

extension UIImageView {
    func setImgWebUrl(url : String, isIndicator : Bool){
        if isIndicator == true{
            SDWebImageActivityIndicator.gray.indicatorView.color = UIColor.systemPink
            self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        }else{
            self.sd_imageIndicator = nil
        }
        
        self.sd_setImage(with: URL(string: url), placeholderImage:UIImage(named: "PlaceHolder"))
    }
}



