//
//  GValidations.swift


import Foundation


class Validation {
    
    
    
       static func isValidName(_ str: String) -> Bool {
        let nameRegEx = "^[a-z A-Z'-]+$"
        let namePred = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return namePred.evaluate(with: str)
    }
    
    //------------------------------------------------------------------------------------------------------------------------

    static func isValidEmail(_ str: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: str)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    
    static func isValidCode(_ str: String) -> Bool {
        let codeRegEx = "^[+0-9]{3}$"
        let codePred = NSPredicate(format:"SELF MATCHES %@", codeRegEx)
        return codePred.evaluate(with: str)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    
    static func isValidPhoneNumber(_ str: String) -> Bool {
        let numberRegEx = "^[0-9][0-9]{7,10}"
        let numberPred = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return numberPred.evaluate(with: str)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    
    static func isValidPassword(_ str: String) -> Bool {
        let passRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,64}$"
        let passPred = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passPred.evaluate(with: str)
    }
}
