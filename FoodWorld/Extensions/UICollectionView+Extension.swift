//
//  UICollectionView+Extension.swift

import Foundation
import UIKit


class SelfSizedCollectionView: UICollectionView {
    
    @IBInspectable var maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.isScrollEnabled = maxHeight < contentSize.height
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        let height = min(contentSize.height + contentInset.top + contentInset.bottom, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}


class SelfSizedTableView: UITableView {
    
    @IBInspectable var maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
            //            self.isScrollEnabled = maxHeight < contentSize.height
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        let height = min(contentSize.height + contentInset.top + contentInset.bottom, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}
