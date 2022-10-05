//
//  CuisineModel.swift
//  FoodWorld

import Foundation

class CuisineModel {
    var docID: String
    var name: String
    var address: String
    var imageURL: String
    var isSelect: Bool
    
    init(docID: String,name: String,address: String,imageURL: String) {
        self.docID = docID
        self.name = name
        self.imageURL = imageURL
        self.address = address
        self.isSelect = false
    }
}


class RestaurantModel {
    var docID: String
    var name: String
    var address: String
    var imageURL: String
    var cuisineName: String
    
    init(docID: String,name: String, cuisineName: String,address: String,imageURL: String) {
        self.docID = docID
        self.name = name
        self.cuisineName = cuisineName
        self.imageURL = imageURL
        self.address = address
    }
}

class RateModel {
    var docID: String
    var name: String
    var rate: String
    var review: String
    
    
    init(docID: String,name: String,rate: String,review: String) {
        self.docID = docID
        self.name = name
        self.review = review
        self.rate = rate
    }
}
