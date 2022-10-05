//
//  HomeVC.swift
//  FoodWorld

import UIKit
import MapKit
import Contacts
import CoreLocation

class HomeVC: UIViewController {

    @IBOutlet weak var colCuisuine: SelfSizedCollectionView!
    @IBOutlet weak var tblList: SelfSizedTableView!
    @IBOutlet weak var sbBar: UISearchBar!
    @IBOutlet weak var btnAddress: UIButton!
    
    var array = [CuisineModel]()
    var arrayRes = [CuisineModel]()
    var arrayData = [JSON]()
    var selectedLocation = CLLocationCoordinate2D()
    var address = ""
    var pendingItem: DispatchWorkItem?
    var pendingRequest: DispatchWorkItem?
    
    @IBAction func btnClick(_ sender: UIButton){
        self.navigationController?.navigationBar.isHidden = false
        if let vc = UIStoryboard.main.instantiateViewController(withClass: MapViewVC.self) {
            vc.selectedLocation = self.selectedLocation
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnProfileClick(_ sender: UIButton){
        self.navigationController?.navigationBar.isHidden = false
        if let vc = UIStoryboard.main.instantiateViewController(withClass: ProfileVC.self) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func setUpAddress() {
        LocationManager.shared.getLocation()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
            let location = LocationManager.shared.getUserLocation() // CLLocation(latitude: 45.5019, longitude: -73.5674)
            location.fetchCityAndCountry { city, country, error in
                guard let city = city, let country = country, error == nil else { return }
                let address = city + ", " + country
                self.btnAddress.setTitle(address, for: .normal)// Rio de Janeiro, Brazil
                let locationData = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
                self.selectedLocation = location.coordinate
                self.getMapData(location: locationData)
            }
            
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpAddress()
        self.getData()
        self.sbBar.delegate = self
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

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout & UINavigationControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CuisineCell", for: indexPath) as! CuisineCell
        print(indexPath.item)
        item.configCell(data: self.array[indexPath.item])
        let tap = UITapGestureRecognizer()
        tap.addAction {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: CuisineDetailsVC.self){
                vc.data = self.array[indexPath.row]
                vc.selectedLocation = self.selectedLocation
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        item.vwCell.isUserInteractionEnabled = true
        item.vwCell.addGestureRecognizer(tap)
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colCuisuine {
            return CGSize(width: UIScreen.main.bounds.width - 40, height: ((120/812) * UIScreen.main.bounds.height))
        }
        return CGSize(width: ((UIScreen.main.bounds.width - 50) / 2), height: ((122/812) * self.view.frame.height))
    }
    
}




extension HomeVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        self.pendingRequest?.cancel()
        
        guard searchBar.text != nil else {
            return
        }
        
        if(searchText.count == 0 || (searchText == " ")){
            return
        }
        
        self.pendingRequest = DispatchWorkItem{ [weak self] in
            
            guard let self = self else { return }
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else { return }
                
                let addressCity = "\(placemarks.first?.locality ?? ""), \(placemarks.first?.country ?? "")"
                self.btnAddress.setTitle(addressCity, for: .normal)
                self.selectedLocation = location.coordinate
                let locationData = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
                self.getMapData(location: locationData)
                self.sbBar.resignFirstResponder()
                // Use your location
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: self.pendingRequest!)
        
    }
    
    
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
                vc.arrayData = self.arrayData[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        cell.vwCell.isUserInteractionEnabled = true
        cell.vwCell.addGestureRecognizer(tap)
        return cell
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
    
    
    
    func getMapData(location: String){
        
        var stringURL = ""
        stringURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=1000&type=restaurant&key=\(APIKEYID)"
        
        let request = URLRequest(url: URL(string: stringURL)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil, let responseData = data else{
                debugPrint(error.debugDescription)
                DispatchQueue.main.async {
                    
                }
                return
            }
            DispatchQueue.main.async {
                print(responseData)
                let jsonData = JSON(responseData)
                if jsonData["status"].stringValue == "OK" {
                    self.arrayRes.removeAll()
                    
                    self.arrayData = jsonData["results"].arrayValue
                    self.tblList.delegate = self
                    self.tblList.dataSource = self
                    self.tblList.reloadData()
                }
            }
        })
        task.resume()
        
    }
    
}

class CuisineCell:  UICollectionViewCell {
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var vwCell: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var consWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vwCell.layer.cornerRadius = 10.0
    }
    
    func configCell(data: CuisineModel) {
        self.lblTitle.text = data.name.description
        self.lblAddress.text = data.address.description
        self.imgLogo.setImgWebUrl(url: data.imageURL, isIndicator: true)
    }
}

class RestaurantCell:  UITableViewCell {
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var vwCell: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
//    @IBOutlet weak var btnBook: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vwCell.layer.cornerRadius = 10.0
    }
    
        func configCell(data: CuisineModel) {
            self.lblTitle.text = data.name.description
            self.lblAddress.text = data.address.description
            self.imgLogo.setImgWebUrl(url: data.imageURL, isIndicator: true)
        }
}
