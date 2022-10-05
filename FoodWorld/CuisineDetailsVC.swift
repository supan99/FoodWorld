//
//  CuisineDetailsVC.swift
//  FoodWorld


import UIKit

class CuisineDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
//        cell.configCell(data: self.arrayRes[indexPath.row])
        
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
    

    @IBOutlet weak var vwTop: UIView!
    @IBOutlet weak var tblList: SelfSizedTableView!
    @IBOutlet weak var vwCuisine: UIView!
    @IBOutlet weak var vwRestaurant: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    var data: CuisineModel!
    var arrayRes = [CuisineModel]()
    var arrayData = [JSON]()
    
    var selectedLocation : CLLocationCoordinate2D!
    
    
    
    @IBAction func btnBooking(_ sender: Any) {
    }
    
    @IBAction func btnSeeAll(_ sender: Any) {
        if let vc = UIStoryboard.main.instantiateViewController(withClass: RestaurantListVC.self) {
            vc.arrayData = self.arrayData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.vwTop.layer.cornerRadius = 16.0
        self.vwTop.layer.maskedCorners = CACornerMask(rawValue: 12)
        self.vwTop.layer.masksToBounds = true
       
        
        self.vwCuisine.layer.cornerRadius = 10.0
        self.vwRestaurant.layer.cornerRadius = 10.0
        
        self.tblList.delegate = self
        self.tblList.dataSource = self
        
        if data != nil {
            self.lblName.text = data.name.description.capitalized
            self.imgProfile.setImgWebUrl(url: data.imageURL, isIndicator: true)
        }
        
        LocationManager.shared.getLocation()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
            let location = LocationManager.shared.getUserLocation() // CLLocation(latitude: 45.5019, longitude: -73.5674)
            var locationData = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            
            if self.selectedLocation != nil {
                locationData = "\(self.selectedLocation.latitude),\(self.selectedLocation.longitude)"
            }
            
            self.getRestaurantData(location: locationData)
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }

    
    func getRestaurantData(location: String){
        
        var stringURL = ""
        stringURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=1000&type=restaurant&keyword=\(data.name)&key=\(APIKEYID)"
        stringURL = stringURL.replacingOccurrences(of: " ", with: "%20")
        
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
