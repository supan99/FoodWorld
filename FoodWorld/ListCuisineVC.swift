//
//  ListCuisineVC.swift
//  FoodWorld

import UIKit

class ListCuisineVC: UIViewController {

    @IBOutlet weak var colCuisuine: SelfSizedCollectionView!
    
    var array = [CuisineModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        // Do any additional setup after loading the view.
    }

}

extension ListCuisineVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout & UINavigationControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCuisineCell", for: indexPath) as! ListCuisineCell
        item.configCell(data: self.array[indexPath.item])
        item.btnEdit.addAction(for: .touchUpInside) {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddCuisinesVC.self){
                vc.data = self.array[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        item.btnDelete.addAction(for: .touchUpInside) {
            Alert.shared.showAlert("", actionOkTitle: "Delete", actionCancelTitle: "Cancel", message: "Are you sure you want to delete this cuisine?") { Bool in
                if Bool {
                    self.deleteData(data: self.array[indexPath.item])
                }
            }
            
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colCuisuine {
            return CGSize(width: ((UIScreen.main.bounds.width - 60) / 2), height: ((280/812) * UIScreen.main.bounds.height))
        }
        return CGSize(width: ((UIScreen.main.bounds.width - 100) / 2), height: ((250/812) * self.view.frame.height))
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
                
                self.colCuisuine.delegate = self
                self.colCuisuine.dataSource = self
                self.colCuisuine.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func deleteData(data: CuisineModel){
        let ref = AppDelegate.shared.db.collection(fCuisine).document(data.docID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully deleted")
                self.getData()
            }
        }
    }
    
}


class ListCuisineCell:  UICollectionViewCell {
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var vwCell: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var consWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vwCell.layer.cornerRadius = 10.0
        self.btnEdit.layer.cornerRadius = 5.0
        self.btnDelete.layer.cornerRadius = 5.0
    }
    
    func configCell(data: CuisineModel) {
        self.lblTitle.text = data.name.description
        self.imgLogo.setImgWebUrl(url: data.imageURL, isIndicator: true)
    }
}
