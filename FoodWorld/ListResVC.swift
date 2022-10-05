//
//  ListResVC.swift
//  FoodWorld


import UIKit

class ListResVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ResListCell", for: indexPath) as! ResListCell
        cell.configData(data: self.array[indexPath.row])
        
        cell.btnEdit.addAction(for: .touchUpInside) {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddRestaurantVC.self){
                vc.data = self.array[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        cell.btnDelete.addAction(for: .touchUpInside) {
            Alert.shared.showAlert("", actionOkTitle: "Delete", actionCancelTitle: "Cancel", message: "Are you sure you want to delete this restaurant?") { Bool in
                if Bool {
                    self.deleteData(data: self.array[indexPath.row])
                }
            }
        }
        return cell
    }
    
    
    @IBOutlet weak var tblList: SelfSizedTableView!
    
    var array = [RestaurantModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRestaurantData()
        // Do any additional setup after loading the view.
    }
    
    func getRestaurantData(){
        _ = AppDelegate.shared.db.collection(fRestaurant).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[fName] as? String, let address: String = data1[fAddress] as? String, let imagePath: String = data1[fImageURL] as? String, let cuisineName: String = data1[fCuisine] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(RestaurantModel(docID: data.documentID, name: name, cuisineName: cuisineName, address: address, imageURL: imagePath))
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
    
    
    func deleteData(data: RestaurantModel){
        let ref = AppDelegate.shared.db.collection(fRestaurant).document(data.docID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully deleted")
                self.getRestaurantData()
            }
        }
    }

}






class ResListCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnEdit.layer.cornerRadius = 5.0
        self.btnDelete.layer.cornerRadius = 5.0
        self.imgView.contentMode = .scaleAspectFill
    }
    
    func configData(data: RestaurantModel){
        self.lblName.text = data.name
        self.lblAddress.text = data.address
        self.imgView.setImgWebUrl(url: data.imageURL, isIndicator: true)
    }
}
