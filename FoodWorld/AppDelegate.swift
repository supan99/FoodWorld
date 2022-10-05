//
//  AppDelegate.swift
//  FoodWorld


import UIKit
@_exported import Firebase
@_exported import FirebaseFirestore
@_exported import FirebaseCore
@_exported import GoogleMaps
@_exported import GooglePlaces
@_exported import SwiftyJSON
@_exported import SendGrid


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var db : Firestore!
    static let shared : AppDelegate = UIApplication.shared.delegate as! AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.firebaseSetUp()
        
        if LocationManager.shared.checkStatus() == .denied || LocationManager.shared.checkStatus() == .notDetermined || LocationManager.shared.checkStatus() == .restricted  {
            LocationManager.shared.getLocation()
        } 
        return true
    }
    
    func firebaseSetUp(){
        FirebaseApp.configure()
        db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        //
        //
    }
    
    override init() {
        super.init()
        GMSServices.provideAPIKey(APIKEYID)
        GMSPlacesClient.provideAPIKey(APIKEYID)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func openLink(){
        if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

