//
//  WelcomeVC.swift
//  FoodWorld


import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnCreateAccount {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: SignUpVC.self){
                vc.modalPresentationStyle = .pageSheet
                vc.isSelect = true
                vc.completionHandlerSend = { (data : Bool) in
                    if data {
                        if let vc = UIStoryboard.main.instantiateViewController(withClass: ForgotPasswordVC.self){
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }else if sender == btnLogin {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: SignUpVC.self){
                vc.modalPresentationStyle = .pageSheet
                vc.isSelect = false
                vc.completionHandlerSend = { (data : Bool) in
                    if data {
                        if let vc = UIStoryboard.main.instantiateViewController(withClass: ForgotPasswordVC.self){
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnCreateAccount.layer.cornerRadius = 12.0
        self.btnLogin.layer.cornerRadius = 12.0
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }

}
