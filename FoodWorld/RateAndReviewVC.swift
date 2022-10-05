//
//  RateAndReviewVC.swift
//  FoodWorld


import UIKit
import SwiftyJSON
import Cosmos

class RateAndReviewVC: UIViewController {

    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var vwRate: CosmosView!
    @IBOutlet weak var tvReview: UITextView!
    @IBOutlet weak var btnReview: UIButton!
    
    var data : JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.vwMain.layer.cornerRadius = 36.0
        self.vwMain.layer.maskedCorners = CACornerMask(rawValue: 3)
        self.btnReview.layer.cornerRadius = 8.0
        self.tvReview.layer.cornerRadius = 10.0
        self.tvReview.layer.borderColor = UIColor.red.cgColor
        self.tvReview.layer.borderWidth = 1.0
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func btnReview(_ sender: UIButton) {
        if tvReview.text.trim() == "" {
            Alert.shared.showAlert(message: "Please enter reviews !!!", completion: nil)
        }else{
            if let email = GFunction.user?.email.description {
                self.submitReview(email: email, resName: self.data["name"].stringValue, resAddess: self.data["vicinity"].stringValue, rate: self.vwRate.rating.description, review: self.tvReview.text.trim(), placeID: self.data["place_id"].stringValue, userID: GFunction.user.docID)
            }
            
        }
    }
    
    func emailSend(email: String, resName:String,resAddess: String, rate:String, review: String,resID: String){
        self.sendEmail(resID: resID, email: email, resName:resName,resAddess: resAddess, rate:rate, review: review){ [unowned self] (result) in
            DispatchQueue.main.async {
                switch result{
                    case .success(_):
                        Alert.shared.showAlert(message: "Your review has been submitted successfully !!!") { (true) in
                            UIApplication.shared.setTab()
                        }
                    case .failure(_):
                        Alert.shared.showAlert(message: "Error", completion: nil)
                }
            }
            
        }
    }
    
    func sendEmail(resID:String, email: String, resName:String,resAddess: String, rate:String, review: String, completion: @escaping (Result<Void,Error>) -> Void) {
        let apikey = "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"
        let devemail = "ravitejareddyk98@gmail.com"
        
        let data : [String:String] = [
            "resName": resName,
            "address": resAddess,
            "rate": rate,
            "review" : review,
            "rateID" : resID
        ]
        
        
        let personalization = TemplatedPersonalization(dynamicTemplateData: data, recipients: email)
        let session = Session()
        session.authentication = Authentication.apiKey(apikey)
        
        let from = Address(email: devemail, name: "FoodWorld")
        let template = Email(personalizations: [personalization], from: from, templateID: "d-76f9c5bae0104dbea78ce5605dbf17b0", subject: "Your review has been submitted!!!")
        
        do {
            try session.send(request: template, completionHandler: { (result) in
                switch result {
                    case .success(let response):
                        print("Response : \(response)")
                        completion(.success(()))
                        
                    case .failure(let error):
                        print("Error : \(error)")
                        completion(.failure(error))
                }
            })
        }catch(let error){
            print("ERROR: ")
            completion(.failure(error))
        }
    }
    
    func submitReview(email: String, resName:String,resAddess: String, rate:String, review: String,placeID: String,userID: String) {
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(fReview).document(placeID).collection(fuserReview).addDocument(data:
                                                                                                            
                                                                                                            [fRevie: review,
                                                                                                             fRating: rate,
                                                                                                             fUserID: userID,
                                                                                                      fRestaurantID: placeID,
                                                                                                              fName: GFunction.user.name
                                                                                                              ]){  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                
                self.emailSend(email: email, resName: resName, resAddess: resAddess, rate: rate, review: review, resID: ref?.documentID ?? "")
            }
        }
    }
    
    
    
}
