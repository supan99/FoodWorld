
//GFunction.swift


import Foundation
import UIKit
import MapKit
@_exported import Photos
@_exported import OpalImagePicker
@_exported import FirebaseAuth
import Contacts

class GFunction {
    
    static let shared: GFunction = GFunction()
    static var user : UserModel!

    //Firebase Authentication Login
    func firebaseRegister(data: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: data, password: "123123") { [weak self] authResult, error in
            guard self != nil else { return }
            //return if any error find
            if error != nil {
                FirebaseAuth.Auth.auth().createUser(withEmail: data, password: "123123") { authResult, error in
                    // ApiManager.shared.removeLoader()
                    //Return if error find
                    if error != nil {
                        return
                    }else{
                        FirebaseAuth.Auth.auth().signIn(withEmail: data, password: "123123") { [weak self] authResult, error in
                            guard self != nil else { return }
                            
                        }
                    }
                }
            }
        }
    }

    func UTCToDate(date:Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date) // string purpose I add here
        let yourDate = formatter.date(from: myString)  // convert your string to date
        formatter.dateFormat = "yyyyMMDDHHmmss"  //then again set the date format whhich type of output you need
        return formatter.string(from: yourDate!) // again convert your date to string
    }
    
    
    //Permissison for camera check is its not given
    func isGiveCameraPermissionAlert(_ viewController: UIViewController, completion: @escaping ((Bool) -> Void)) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            completion(true)
            
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    completion(true)
                    
                } else {
                    completion(false)
                    print("Disable")
                    
                    var errorMessage : String = ""
                    errorMessage = "Enable to access your camera roll to upload your photos with the app."
                    
                    let permissionAlert = UIAlertController(title: "FoodWorld Would like to access your photos?" , message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                    
                    permissionAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        AppDelegate.shared.openLink()
                    }))
                    
                    permissionAlert.addAction(UIAlertAction(title: "Dont Allow", style: .cancel, handler: { (action: UIAlertAction!) in
                        
                    }))
                    
                    DispatchQueue.main.async { [weak self] in
                        guard self != nil else { return }
                        viewController.present(permissionAlert, animated: true, completion: nil)
                    }
                }
            })
        }
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
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}


extension CLPlacemark {
    /// street name, eg. Infinite Loop
    var streetName: String? { thoroughfare }
    /// // eg. 1
    var streetNumber: String? { subThoroughfare }
    /// city, eg. Cupertino
    var city: String? { locality }
    /// neighborhood, common name, eg. Mission District
    var neighborhood: String? { subLocality }
    /// state, eg. CA
    var state: String? { administrativeArea }
    /// county, eg. Santa Clara
    var county: String? { subAdministrativeArea }
    /// zip code, eg. 95014
    var zipCode: String? { postalCode }
    /// postal address formatted
    @available(iOS 11.0, *)
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}



class LocationManager: NSObject , CLLocationManagerDelegate {
    
    static let shared : LocationManager = LocationManager()
    var location            : CLLocation = CLLocation()
    var locationManager     : CLLocationManager = CLLocationManager()
    
    //---------------------------------------------------------------------
    
    //MARK: - Current Lat Long
    
    //TODO: To get location permission just call this method
    func getLocation() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
       
    }
    
    //TODO: To get permission is allowed or declined
    func checkStatus() -> CLAuthorizationStatus{
        return CLLocationManager.authorizationStatus()
    }
    
    //TODO: To get user's current location
    func getUserLocation() -> CLLocation {
        return location
    }
    
    // Get String Latitude
    func getLat()-> String {
        //return String(format: "%.4f", self.location.coordinate.latitude)
        return String(self.location.coordinate.latitude)
    }
    
    // Get String Longitude
    func getLong()-> String {
        //return String(format: "%.4f", self.location.coordinate.longitude)
        return String(self.location.coordinate.longitude)
    }
    
    //MARK: Delegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[0]
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
                
            case .denied:
                print("Permission Denied")
                break
            case .notDetermined:
                print("Permission Not Determined G")
                break
                
            default:
                print("\(location.coordinate.latitude)")
                print("\(location.coordinate.longitude)")
                break
        }
    }
    
    func isDisableLocationPermission()-> Bool {
        return CLLocationManager.authorizationStatus() == .denied
    }
    
    func askForLocationPermision(){
        
        if CLLocationManager.authorizationStatus() == .denied /*|| curruntSettings?.types == []*/ {
            print("Disable")
            
            var errorMessage : String = ""
            if CLLocationManager.authorizationStatus() == .denied{
                
                errorMessage = "We need to access your location to show your relevant search results"
            }else {
                //                    errorMessage = kNotificatinPermionDenied
            }
            
            let LocationAlert = UIAlertController(title: "Your location will help to get the best & nearby restaurant for you. Please turn on location service in your device settings." , message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            
            LocationAlert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (action: UIAlertAction!) in
                // print("Handle Ok logic here")
                UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL)
            }))
            
            LocationAlert.addAction(UIAlertAction(title: "Don't Allow", style: .cancel, handler: { (action: UIAlertAction!) in
                // print("Handle Cancel logic here")
                
            }))
            
            DispatchQueue.main.async {
                UIApplication.topViewController()?.present(LocationAlert, animated: true, completion: nil)
            }
        }
    }
    
    
   
}

