//
//  RestaurantListVC.swift
//  FoodWorld


import UIKit

class RestaurantListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        
        cell.lblTitle.text = self.arrayData[indexPath.row]["name"].stringValue
        cell.lblAddress.text = self.arrayData[indexPath.row]["vicinity"].stringValue
        GFunction.shared.getImageURL(photoRef: self.arrayData[indexPath.row]["photos"][0]["photo_reference"].stringValue,image: cell.imgLogo)
        
        
        
        let tap = UITapGestureRecognizer()
        tap.addAction {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: RestaurantDetailsVC.self){
                vc.data = self.arrayRes[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        cell.vwCell.isUserInteractionEnabled = true
        cell.vwCell.addGestureRecognizer(tap)
        return cell
    }
    
    
    @IBOutlet weak var vwTop:  UIView!
    @IBOutlet weak var vwBottom: UIView!
    @IBOutlet weak var btnBooking: UIButton!
    @IBOutlet weak var tblList: SelfSizedTableView!
    
    
    var data: CuisineModel!
    var arrayRes = [CuisineModel]()
    var arrayData = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.vwTop.layer.cornerRadius = 16.0
        self.vwTop.layer.maskedCorners = CACornerMask(rawValue: 12)
       

        self.tblList.delegate = self
        self.tblList.dataSource = self
        
//        self.getRestaurantData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    func getRestaurantData(){
        _ = AppDelegate.shared.db.collection(fRestaurant).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.arrayRes.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[fName] as? String, let address: String = data1[fAddress] as? String, let imagePath: String = data1[fImageURL] as? String {
                        
                        self.arrayRes.append(CuisineModel(docID: data.documentID, name: name, address: address, imageURL: imagePath))
                    }
                }
                
                self.tblList.delegate = self
                self.tblList.dataSource = self
                self.tblList.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }

}
