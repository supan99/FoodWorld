//
//  SignUpVC.swift
//  FoodWorld


import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnApple: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var vwConfirmPassword: UIView!
    @IBOutlet weak var vwName: UIView!
    @IBOutlet weak var vwAddress: UIView!
    
    var isSelect : Bool = true
    var flag: Bool = true
    var completionHandlerSend : ((_ data : Bool) -> Void)? = nil
    private let socialLoginManager: SocialLoginManager = SocialLoginManager()
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnCreate {
            self.isSelect = true
            self.updateView()
        }else if sender == btnLogin {
            self.isSelect = false
            self.updateView()
        } else if sender == btnRegister {
            self.flag = false
            if sender.isSelected {
                let error = self.loginValidation(email: self.txtEmail.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "")
                if error == "" {
                    if self.txtEmail.text?.trim() == "Admin@gmail.com" && self.txtPassword.text?.trim() == "Admin@123" {
                        UIApplication.shared.setAdmin()
                    }else{
                        self.firebaseLogin(data: self.txtEmail.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "")
                    }
                    
                } else {
                    Alert.shared.showAlert(message: error, completion: nil)
                }
            }else{
                let error = self.validation(name: self.txtName.text?.trim() ?? "", email: self.txtEmail.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "", confirmPass: self.txtConfirmPassword.text?.trim() ?? "")
                
                if error == "" {
                    self.firebaseRegister(data: self.txtEmail.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "", name: self.txtName.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "")
                }else{
                    Alert.shared.showAlert(message: error, completion: nil)
                }
            }
            self.updateView()
                
        }else if sender == btnForgotPassword {
            self.completionHandlerSend?(true)
            self.dismiss(animated: false, completion: nil)
        }else if sender == btnApple {
            self.socialLoginManager.performAppleLogin()
        }
    }
    
    private func validation(name: String, email: String, address: String, password: String, confirmPass: String) -> String {
        
        if name.isEmpty {
            return STRING.errorEnterName
            
        } else if email.isEmpty {
            return STRING.errorEmail
            
        } else if !Validation.isValidEmail(email) {
            return STRING.errorValidEmail
            
        } else if address.isEmpty {
            return STRING.errorCity
            
        } else if password.isEmpty {
            return STRING.errorPassword
            
        } else if password.count < 8 {
            return STRING.errorPasswordCount
            
        } else if !Validation.isValidPassword(password) {
            return STRING.errorValidCreatePassword
            
        } else if confirmPass.isEmpty {
            return STRING.errorConfirmPassword
            
        } else if password != confirmPass {
            return STRING.errorPasswordMismatch
            
        } else {
            return ""
        }
    }
    
    func loginValidation(email: String, password: String) -> String {
        
        if email.isEmpty {
            return STRING.errorEmail
        }else if !Validation.isValidEmail(email) {
            return STRING.errorValidEmail
        } else if password.isEmpty {
            return STRING.errorPassword
        } else if password.count < 8 {
                return STRING.errorPasswordCount
        } else if !Validation.isValidPassword(password) {
            return STRING.errorValidCreatePassword
        } else {
            return ""
        }
    }
    
    func showView(data: Bool){
        DispatchQueue.main.async {
            self.lblEmail.isHidden = data
            self.lblPassword.isHidden = data
            self.vwName.isHidden = data
            self.vwAddress.isHidden = data
            self.vwConfirmPassword.isHidden = data
            self.btnForgotPassword.isHidden = !data
        }
    }
    
    func updateView(){
        self.btnLogin.isSelected = !self.isSelect
        self.btnCreate.isSelected = self.isSelect
        self.isSelect ? self.showView(data: false) : self.showView(data: true)
        self.btnRegister.isSelected = !self.isSelect
        self.btnApple.isSelected = !self.isSelect
    }
    
    private func setUpStyle(){
        self.vwMain.layer.cornerRadius = 36.0
        self.vwMain.layer.maskedCorners = CACornerMask(rawValue: 3)
        self.btnRegister.layer.cornerRadius = 12.0
        self.btnApple.layer.cornerRadius = 12.0
        self.updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpStyle()
        
        self.txtEmail.text = "ios.test394@gmail.com"
        self.txtPassword.text = "Test@1234"
        self.socialLoginManager.delegate = self
        // Do any additional setup after loading the view.
    }
}


//MARK:- Extension for Login Function
extension SignUpVC {

    func firebaseLogin(data: String, password: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: data, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            //return if any error find
            if error != nil {
                Alert.shared.showAlert(message: error?.localizedDescription ?? "", completion: nil)
            }else{
                self?.loginUser(email: data)
            }
        }
    }
    
    func firebaseRegister(data: String, password: String, name: String, address: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: data, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            //return if any error find
            if error != nil {
                Alert.shared.showAlert(message: error?.localizedDescription ?? "", completion: nil)
            }else{
                let uid = FirebaseAuth.Auth.auth().currentUser?.uid
                self?.createAccount(name: name, email: data, address: address, password: password, uid: uid!)
            }
        }
    }
    
    func createAccount(name: String, email: String, address: String, password: String, uid: String) {
        AppDelegate.shared.db.collection(fUser).document(uid).setData([fEmail: email,
                                                                        fName: name,
                                                                     fAddress: address,
                                                                       fImage: "",
                                                                       "id": uid,
                                                                   fPassword : password]){  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
               
                GFunction.shared.firebaseRegister(data: email)
                GFunction.user = UserModel(docID: uid, name: name,address: address, email: email, password: password)
                UIApplication.shared.setTab()
            }
        }
    }
    
    func loginUser(email:String) {
        
        _ = AppDelegate.shared.db.collection(fUser).whereField(fEmail, isEqualTo: email).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.documents.count != 0 {
                let data1 = snapshot.documents[0].data()
                let docId = snapshot.documents[0].documentID
                if let name: String = data1[fName] as? String, let email: String = data1[fEmail] as? String {
                    GFunction.user = UserModel(docID: docId, name: name,address: data1[fAddress] as? String ?? "", email: email, password: data1[fPassword] as? String ?? "")
                }
                UIApplication.shared.setTab()
            }
        }
        
    }
}


extension SignUpVC: SocialLoginDelegate {
    
    func socialLoginData(data: SocialLoginDataModel) {
        print("Social Id==>", data.socialId ?? "")
        print("First Name==>", data.firstName ?? "")
        print("Last Name==>", data.lastName ?? "")
        print("Email==>", data.email ?? "")
        print("Login type==>", data.loginType ?? "")
       
        
        self.txtEmail.text = data.email ?? ""
        
    }
}
