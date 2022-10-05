//
//  AdminHomeVC.swift
//  FoodWorld


import UIKit

class AdminHomeVC: UIViewController {

    @IBOutlet weak var btnRestaurant: UIButton!
    @IBOutlet weak var btnRestaurantAll: UIButton!
    @IBOutlet weak var btnCuisinesAll: UIButton!
    @IBOutlet weak var btnCuisines: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    @IBAction func btnAdd(_ sender: UIButton) {
        if sender == btnRestaurant {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddRestaurantVC.self){
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender == btnCuisines {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddCuisinesVC.self){
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if sender == btnLogout {
            UIApplication.shared.setStart()
        } else if sender ==  btnRestaurantAll {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: ListResVC.self){
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender == btnCuisinesAll {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: ListCuisineVC.self){
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnCuisines.layer.cornerRadius = 10.0
        self.btnRestaurant.layer.cornerRadius = 10.0
        self.btnRestaurantAll.layer.cornerRadius = 10.0
        self.btnLogout.layer.cornerRadius = 10.0
        self.btnCuisinesAll.layer.cornerRadius = 10.0
        // Do any additional setup after loading the view.
    }
}
