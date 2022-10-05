//
//  ForgotSuccessVC.swift
//  FoodWorld


import UIKit

class ForgotSuccessVC: UIViewController {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var backToLogin: UIButton!
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnSubmit {
            self.navigationController?.popViewController(animated: true)
        }else if sender == backToLogin {
            UIApplication.shared.setStart()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backToLogin.layer.cornerRadius = 10.0
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
