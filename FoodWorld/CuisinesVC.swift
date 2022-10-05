//
//  CuisinesVC.swift
//  FoodWorld


import UIKit

class CuisinesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCusineCell", for: indexPath) as! SelectCusineCell
        let data = self.array[indexPath.row]
        cell.configCell(data: data)
        
        let tap = UITapGestureRecognizer()
        tap.addAction {
            self.array[indexPath.row].isSelect = !self.array[indexPath.row].isSelect
            self.tblList.reloadData()
        }
        cell.vwMain.isUserInteractionEnabled = true
        cell.vwMain.addGestureRecognizer(tap)
        
        cell.selectionStyle = .none
        return cell
    }
    

    @IBOutlet weak var tblList: SelfSizedTableView!
    @IBOutlet weak var vwMain: UIView!
    
    
    var array = [CuisineModel]()
    var completionHandlerSend : ((_ arrData : [String]) -> Void)? = nil
    
    
    @IBAction func btnClear(_ sender: UIButton) {
        self.array = self.array.map({ CuisineModel in
            let data = CuisineModel
            data.isSelect = false
            return data
        })
        self.tblList.reloadData()
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnOk(_ sender: UIButton) {
        var strArr = [String]()
        let data = self.array.filter({$0.isSelect == true})
        for myData in data {
            strArr.append(myData.name)
        }
        self.completionHandlerSend?(strArr)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        self.vwMain.layer.cornerRadius = 36.0
        self.vwMain.layer.maskedCorners = CACornerMask(rawValue: 3)
        self.tblList.delegate = self
        self.tblList.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    
    func getData(){
        _ = AppDelegate.shared.db.collection(fCuisine).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[fNamE] as? String, let imagePath: String = data1[fImageURL] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(CuisineModel(docID: data.documentID, name: name, address: "", imageURL: imagePath))
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




class SelectCusineCell: UITableViewCell {
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var vwMain: UIView!
    
    func configCell(data: CuisineModel){
        self.lblName.text = data.name
        self.btnSelect.isSelected = data.isSelect
    }
}
