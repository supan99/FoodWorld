//
//  UserModel.swift
//  FoodWorld

import Foundation


class UserModel {
    var docID: String
    var name: String
    var address: String
    var email: String
    var password: String
    
    
    init(docID: String,name: String,address: String,email: String,password:String) {
        self.docID = docID
        self.name = name
        self.email = email
        self.address = address
        self.password = password
    }
}
