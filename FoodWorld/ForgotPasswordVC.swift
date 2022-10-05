//
//  ForgotPasswordVC.swift
//  FoodWorld


import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBAction func btnSubmitClick(_ sender: UIButton) {
        self.validation(email: self.txtEmail.text?.trim() ?? "" )
        
    }
    
    private func validation(email: String) {
        if email.isEmpty {
            Alert.shared.showAlert(message: STRING.errorEmail, completion: nil)
        }else if !Validation.isValidEmail(email) {
            Alert.shared.showAlert(message: STRING.errorValidEmail, completion: nil)
        }else{
            
            let auth = Auth.auth()
            
            auth.sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    Alert.shared.showAlert(message: error.localizedDescription, completion: nil)
                    return
                }
                
                if let vc = UIStoryboard.main.instantiateViewController(withClass: ForgotSuccessVC.self) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnSubmit.layer.cornerRadius = 10.0

        // Do any additional setup after loading the view.
    }
}
