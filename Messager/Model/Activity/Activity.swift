//
//  Activity.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import Foundation
import CoreLocation

public struct Activity: Codable {
    let uid: String?      // uid of the application
    let userId: String?   // uid of the activity initiator
    let likeCount: Int? = nil  // number of likes
    let shareCount: Int? = nil // number of share to others..
    let read: Int? = nil
    let createDate: Double?
    
//    var pendingApp: [String]? = nil // array of uid of activity_application
//    var approvedApp: [String]? = nil // array of uid of activity_application
    
    let actTitle: String?
    let actDetail: String?
    let imageId: String?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userId
        case likeCount
        case shareCount
        
        case createDate
        
//        case pendingApp
//        case approvedApp
        
        case actTitle
        case actDetail
        case imageId
    }
    
    enum Catogory: String, CaseIterable {
        case Sports
        case ESports
        case Recreation
        case Movie
        case OutdoorsAdventure = "Outdoor Adventure"
        case Learning
        case Photography
        case FoodNDrink
        case Music
        case Games
        case Pet
        case Shopping
        case Dance
        case Social
    }
}



// example
public struct City: Codable {

    let name: String
    let state: String?
    let country: String?
    let isCapital: Bool?
    let population: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case state
        case country
        case isCapital = "capital"
        case population
    }

}
