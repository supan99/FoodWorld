////
////  GoogleLoginData.swift
//
//
import Foundation
import AuthenticationServices
//import GoogleSignIn
//
struct SocialLoginDataModel {
    
    init() {
        
    }
    
    var socialId: String!
    var loginType: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var profileImage: String?
}

protocol SocialLoginDelegate: AnyObject {
    func socialLoginData(data: SocialLoginDataModel)
}

class SocialLoginManager: NSObject, ASAuthorizationControllerDelegate {
    
    //MARK: Class Variable
    weak var delegate: SocialLoginDelegate? = nil
    
    //init
    override init() {
        
    }
}

//MARK : Apple Login
extension SocialLoginManager {
    
    //MARK: Apple Login Methods
    /// Open apple login view
    @available(iOS 13.0, *)
    func performAppleLogin() {
        
        //request
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let authoriztionRequest = appleIdProvider.createRequest()
        authoriztionRequest.requestedScopes = [.fullName, .email]
        
        //Apple’s Keychain sign in // give the resukt of save id - password for this app
        let passwordProvider = ASAuthorizationPasswordProvider()
        let passwordRequest = passwordProvider.createRequest()

        //create authorization controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [authoriztionRequest]) //[authoriztionRequest, passwordRequest]
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

//MARK : Apple Login Delegate
@available(iOS 13.0, *)
extension SocialLoginManager: ASAuthorizationControllerPresentationContextProviding {
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return UIApplication.topViewController()!.view.window!
        return UIApplication.topViewController()!.view.window!
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        print(appleIDCredential.user, appleIDCredential.fullName as Any, appleIDCredential.email as Any)
        var dataObj: SocialLoginDataModel = SocialLoginDataModel()
        dataObj.socialId = appleIDCredential.user
        dataObj.loginType = "A"
        dataObj.firstName =  appleIDCredential.fullName?.givenName ?? ""
        dataObj.lastName = appleIDCredential.fullName?.familyName ?? ""
        dataObj.email = appleIDCredential.email ?? ""
        delegate?.socialLoginData(data: dataObj)
        
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        Alert.shared.showAlert(message: "Something went wrong", completion: nil)
    }
}
