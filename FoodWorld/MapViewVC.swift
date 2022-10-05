//
//  MapViewVC.swift
//  FoodWorld


import UIKit
import MapKit

class MapViewVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView:  MKMapView!
    
    
    var selectedLocation : CLLocationCoordinate2D!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            LocationManager.shared.getLocation()
            
            let locations = LocationManager.shared.getUserLocation()
            var mUserLocation:CLLocation = locations
            var center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
            
            
            var location = "\(mUserLocation.coordinate.latitude),\(mUserLocation.coordinate.longitude)"
            
            
            if self.selectedLocation != nil {
                center = self.selectedLocation
                location = "\(self.selectedLocation.latitude),\(self.selectedLocation.longitude)"
            }
            
            let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.getMapData(location: location)
            self.mapView.setRegion(mRegion, animated: true)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(mRegion, animated: true)
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func getMapData(location: String){
        
        var stringURL = ""
        stringURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=5000&type=restaurant&key=\(APIKEYID)"
        
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
                    
                    let arrayData = jsonData["results"].arrayValue
                    if arrayData.count > 0 {
                        for data in arrayData {
                            let point = MKPointAnnotation()
                            
                            let pointlatitude = data["geometry"]["location"]["lat"].doubleValue
                            let pointlongitude = data["geometry"]["location"]["lng"].doubleValue
                            point.title = data[fName].stringValue
                            
                            point.coordinate = CLLocationCoordinate2DMake(pointlatitude ,pointlongitude)
                            //print(point.coordinate)
                            self.mapView.addAnnotation(point)
                        }
                    }
                }
            }
        })
        task.resume()
        
    }

}
