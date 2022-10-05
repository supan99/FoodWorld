//
//  Alert.swift


import Foundation
import UIKit

class Alert {
    
    /// Shared instance
    static let shared = Alert()
    
    ///Init
    private init() {
        
    }
    
}


// MARK: UIAlertController
extension Alert {
    
    /// Show normal ok - cancel alert with action
    ///
    /// - Parameters:
    ///   - title: Alert title
    ///   - actionOkTitle: Ok action button title
    ///   - actionCancelTitle: Cancel action button title
    ///   - message: Alert message
    ///   - completion: Action completion return true if action is ok else false for cancel
    func showAlert(_ title : String = ""/* Bundle.appName() */, actionOkTitle : String = "Ok" , actionCancelTitle : String = "" , message : String, completion: ((Bool) -> ())? ) {
        
        let alert : UIAlertController = UIAlertController(title: "", message: message , preferredStyle: .alert)
        
        let actionOk : UIAlertAction = UIAlertAction(title: actionOkTitle, style: .destructive) { (action) in
            if completion != nil {
                completion!(true)
            }
        }
        alert.addAction(actionOk)
        
        if actionCancelTitle != "" {
            let actionCancel : UIAlertAction = UIAlertAction(title: actionCancelTitle, style: .cancel) { (action) in }
            alert.addAction(actionCancel)
        }
        
        alert.view.tintColor = UIColor.black
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    /// Show alert for multiple button action
    ///
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    ///   - actionTitles: Array of button action title
    ///   - actions: Array of UIAlertAction actions
    func showAlert(title: String = "", message: String, actionTitles:[String], actions:[((UIAlertAction) -> Void)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        alert.view.tintColor = UIColor.black
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func showingHud() {
        // self.startAnimating(type: .circleStrokeSpin, color: UIColor.black, backgroundColor: UIColor.black.withAlphaComponent(0.25))
    }
    
    //FIXME:-
    func hidingHud() {
        //self.stopAnimating()
    }
}
