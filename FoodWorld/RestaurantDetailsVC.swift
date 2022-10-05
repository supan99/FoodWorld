//
//  RestaurantDetailsVC.swift
//  FoodWorld


import UIKit
import SwiftyJSON
import Cosmos

class RestaurantDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
        cell.configCell(data: self.array[indexPath.row])
        return cell
    }
    

    @IBOutlet weak var vwTop: UIView!
    @IBOutlet weak var vwBottom: UIView!
    @IBOutlet weak var vwDetails: UIView!
    @IBOutlet weak var btnBooking: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var tblList: UITableView!
    
    var data: CuisineModel!
    var arrayData:  JSON!
    var array = [RateModel]()
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        if let vc = UIStoryboard.main.instantiateViewController(withClass: RateAndReviewVC.self) {
            vc.data = self.arrayData
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnShare(_ sender: UIButton) {
        self.presentActivitySheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.vwTop.layer.cornerRadius = 16.0
        self.vwTop.layer.maskedCorners = CACornerMask(rawValue: 12)
        self.vwBottom.layer.cornerRadius = 16.0
        self.vwBottom.layer.maskedCorners = CACornerMask(rawValue: 3)
        self.vwDetails.layer.cornerRadius = 10.0
        self.btnBooking.layer.cornerRadius = 10.0
        
        self.tblList.delegate = self
        self.tblList.dataSource = self
        
        if arrayData != nil {
            self.getImageURL(photoRef: self.arrayData["photos"][0]["photo_reference"].stringValue, image: self.imgProfile)
            self.lblName.text = self.arrayData["name"].stringValue
            self.lblAddress.text = self.arrayData["vicinity"].stringValue
        }
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getData(placeId: self.arrayData["place_id"].stringValue)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }

    
    func presentActivitySheet(){
        let textTOShare = "\(self.arrayData["name"].stringValue) \n\(self.arrayData["vicinity"].stringValue)".description
        let presentActivityVC = UIActivityViewController(activityItems: [textTOShare], applicationActivities: nil)
        presentActivityVC.popoverPresentationController?.sourceView = self.view
        self.present(presentActivityVC, animated: true, completion: nil)
    }
    
    func getImageURL(photoRef: String, image: UIImageView) {
        var stringURL = ""
        stringURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=\(photoRef)&key=\(APIKEYID)"
        
        let request = URLRequest(url: URL(string: stringURL)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil, let url = response?.url else{
                debugPrint(error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                image.setImgWebUrl(url: url.description, isIndicator: true)
            }
            
        })
        task.resume()
    }
    
    
    func getData(placeId: String){
        _ = AppDelegate.shared.db.collection(fReview).document(placeId).collection(fuserReview).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if  let name: String = data1[fName] as? String,
                        let rate: String = data1[fRating] as? String,
                        let review: String = data1[fRevie] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(RateModel(docID: data.documentID, name: name, rate: rate, review: review))
                    }
                }
                
                self.tblList.delegate = self
                self.tblList.dataSource = self
                self.tblList.reloadData()
            }else{
//                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
}



class RatingCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var vwRate: CosmosView!
    
    
    func configCell(data: RateModel) {
        self.lblName.text = data.name
        self.lblAddress.text = data.review
        self.vwRate.rating = Double(data.rate) ?? 0.0
    }
    
}
