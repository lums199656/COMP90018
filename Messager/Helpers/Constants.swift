//
//  Constants.swift
//  Messager
//
//  Created by 陆敏慎 on 27/9/20.
//

import Foundation

public let userDefaults = UserDefaults.standard
public let kFILEREFERENCE = "gs://comp90018-19be3.appspot.com"





public let kNUMBEROFMESSAGES = 30


public let kCURRENTUSER = "currentUser"
public let kSTATUS = "status"
public let kFIRSTRUN = "firstRUN"

public let kCHATROOMID = "chatRoomId"
public let kSENDERID = "senderId"

public let kSENT = "Sent"
public let kREAD = "Read"

public let kTEXT = "text"
public let kPHOTO = "photo"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"


public let kDATE = "date"
public let kREADDATE = "date"

public let kADMINID = "adminId"
public let kMEMBERIDS = "memberIds"

public var kCURRENTUSERNAME = "nil"


struct K {
    
//    static let
    
    struct Store {
        static let activityImage = "activity-images"
    }
    
    struct FStore {
        static let user = "Users"
        static let act = "Activities"
        static let app = "Applications"
    }
    
    struct Activity {
        static let detail = "actDetail"
        static let title = "actTitle"
        static let image = "imageId"
        static let uid = "uid" //document id
        static let user = "actCreatorId"
        static let groupSize = "actGroupSize"
        static let status = "actStatus"
        static let read_dict = "read_dic"
        static let join = "join"
        static let location = "location"
        static let category = "category"
        static let locationString = "locationString"
    }
    
}
