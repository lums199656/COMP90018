//
//  DBSeeding.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import Foundation
import Firebase
import CoreLocation

struct DBSeeding {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    init(_ doSeed: Bool) {
        
        if doSeed {
            seedActivity()
        }
    }

    
    
    func seedActivity() {
        let actCreatorIds = ["fguCsV6dRLYx3TLsmNGo4TJU0lJ3",
                            "f5DCebQL7hagccMVyYVguVnubYL2",
                            "n9Zder5HBDW1wafVfQsfG5a1gUr2"]
        
        let actTitles = ["漫威复仇者", "队长小翼 新秀崛起",
                        "刀剑神域", "Survivalists!!!", "女神异闻录５"]
        
        let actDetails = [ "单人战役模式需要一次性网络连接；多人游戏及下载上线后,内容需要网络连接。",
                           "深受追捧的《队长小翼》漫画在全球范围内依旧热度不减",
                           "世界绝不会忘记",
                           "全世界累计销量突破320万份的《___》，以系列首次的动作RPG形式登场。！",
                           "精彩刺激", "最高质素"]
        let actCats = ["Sports" , "ESports", "Recreation", "Movie", "OutdoorsAdventure", "Learning",
                       "Phtography", "FoodNDrink"]
        
        // -----------------------------------------
        func uploadImage(from image: UIImage, to cloudName: String) {
            let storageRef = storage.reference()
            let activityImageRef = storageRef.child("activity-images")
            
            let cloudFileRef = activityImageRef.child(cloudName)
            
            guard let data = image.jpegData(compressionQuality: 1) else { return }  // data: image to be uploaded
            
            let _ = cloudFileRef.putData(data, metadata: nil) { metadata, error in
                guard let _ = metadata else { return }  // if metadata is nil, return
                
                print("Success upload image \(cloudName)")
            }
        }
        
        
        for i in 0...9 {
            
            let imageName = "port" + String(i)
            let image = UIImage(named: imageName)
            let actRef = db.collection(K.FStore.act).document()
            
            // _. seed image
            uploadImage(from: image!, to: actRef.documentID)
            
            // _. seed activity
            let actTitle = actTitles.randomElement()! + String(Int.random(in: 1000...2000))
            let actDetail = actDetails.randomElement()! + String(Int.random(in: 1000...2000))
            let actCreatorId = actCreatorIds.randomElement()!
            
            
            // __. Location
            let lat = CLLocationDegrees(-37.80432118411683)
            let lon = CLLocationDegrees(144.9656667785954)
            
            var geoPoint: GeoPoint?
            geoPoint = GeoPoint.init(latitude: lat, longitude: lon)
            
            let readDic = [actCreatorId: 1]
            let join = [actCreatorId]
            
            actRef.setData([
                "actDetail": actDetail,
                "actTitle": actTitle,
                "createDate": Date() as Any,
                "startDate": Date().advanced(by: TimeInterval(60*Int.random(in: 60...300))) as Any,
                "endDate": Date().advanced(by: TimeInterval(60*Int.random(in: 300...900))) as Any,
                "location": geoPoint as Any,
                "locationString": "309 Cocoa St, Carlton" as Any,
                "category": actCats.randomElement()! as Any,
                "imageId": actRef.documentID,
                "read_dic": readDic as Any,
                "actCreatorId": actCreatorId,
                "actStatus": 0, //0: awaiting, 1: ready, 2: finish
                "actGroupSize": 5,
                "join": join as Any
            ])
            
            print("Activity Document added with ID: \(actRef.documentID)")
        }
    }
    
}
