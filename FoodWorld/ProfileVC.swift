//
//  ProfileVC.swift
//  FoodWorld

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnLogout.layer.cornerRadius = 10.0
        
        
        if let user = GFunction.user {
            self.txtAddress.text = user.address
            self.txtEmail.text = user.email
            self.txtFullName.text = user.name.capitalized
            self.txtEmail.isUserInteractionEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnLogout(_ sender: UIButton) {
        UIApplication.shared.setStart()
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        let error  = self.validation(name: self.txtFullName.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "")
        
        if error.isEmpty {
            self.updateProfile(uid: GFunction.user.docID, name: self.txtFullName.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "")
        }else{
            Alert.shared.showAlert(message: error, completion: nil)
        }
        
    }
    
    func validation(name: String, address: String) -> String {
        if name.isEmpty {
            return "Please enter name"
        }else if address.isEmpty {
            return "Please enter address"
        }
        return ""
    }
    
    func updateProfile(uid: String,name: String, address: String) {
        let ref = AppDelegate.shared.db.collection(fUser).document(uid)
        ref.updateData([
            fName: name,
            fAddress: address,
        ]){  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                UIApplication.shared.setTab()
            }
        }
    }
}
