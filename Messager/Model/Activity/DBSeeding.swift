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
        let actCreatorIds = ["wE1e5yLPxEY6nb7CbRzrJ02mIYW2",
                            "uUVZBpOQT5Mg9GNoxFORNj5vAPz1",
                            "n9Zder5HBDW1wafVfQsfG5a1gUr2",
                            "fguCsV6dRLYx3TLsmNGo4TJU0lJ3",
                            "f5DCebQL7hagccMVyYVguVnubYL2",
                            "Y31FESSEmZgb6F9mPQoQLrgymnQ2",
                            "J0tipz7ZPGWJhgg8ZigdPxHyiSS2",
                            "1bcX8hdquKeNvl9DAxNbIfrimTy1",
        ]
        struct activity {
            var title: String
            var detail: String
            var location: String?
        }
        
        let activities = [ activity(title: "Day Trip @ MelbourneCentral", detail: "Let’s have a day trip at Melbourne Central ! Let’s grab some bubble tea and chips!", location: "Melbourne central station"),
                           activity(title: "Study at RMIT Library", detail: "Let’s study at RMIT library together ! It’ll be better if you are a current RMIT student", location: "L5, Building 88 RMIT University"),
                           activity(title: "Switch Game Night", detail: "Do you wanna play Nintendo Switch all night long with us? Join us NOW!", location: "500 Swanston Street"),
                           activity(title: "Super Mario Maker 2 Online Event", detail: "We’d like to hold a mini-sized Super Mario Maker 2 Online Competition this week. Are you ready to fight?", location: "Online"),
                           activity(title: "Language Exchange Hub- Japanese and English", detail: "Are you a Japanese speaker or an English speaker? Are you planning to learn these two languages? JOIN US at the language exchange hub!", location: "28 Bouverie Street"),
                           
                           activity(title: "League of Legend S12 ", detail: "Binge watching the final game of the LOL tournament", location: "The Vision Apartment"),
                           activity(title: "Karaoke All Night", detail: "Kick back and relax, we'll bring the song, but BYOB!", location: "3F, 1423 Elisabeth St"),
                           
                           activity(title: "Let's PLAY!", detail: "Need a guy to join us to play the glory of the king", location: nil),
                           activity(title: "Exihibition", detail: "Recently a new exhibition hall has opened, and I want to invite some friends to go together!", location: "Southeast Melbourne"),
                           activity(title: "Take care of stray cats", detail: "Our family has adopted a lot of stray cats, do any friends want to adopt? FOR FREE! And we decide to have a party the day after tomorrow!", location: "500 Swanston Street"),
                           activity(title: "The most authentic hot pot!", detail: "We’d like to have a hotpot on this Saturday night. Are you ready to join us?", location: "One on Center Ave"),
                           activity(title: "Having a steak!", detail: "I deadly want to have a steak! Urgently need a fellow to join me!", location: "20 Kingston Street"),
                           
                           activity(title: "BBQ&Hot Pot", detail: "Get some great bbq & chines hot pot at NO. 1 and meet new friends!", location: "83 Franklin Street Melbourne"),
                           activity(title: "DOGs Party!", detail: "Make some new friends for both you and your dog!", location: "Clayton Reserve, North Melbourne"),
                           activity(title: "KARAOKE NIGHT", detail: "Party and Sing Karaoke like a Rock Star!", location: "Ichi Ni Nana, 127 Brunswick Street, Melbourne"),
                           activity(title: "Online Reading Club", detail: "Keep reading makes you a better person. Everyone will share a book they read this week.", location: "Online"),
                           activity(title: "Online Flea Market", detail: "Prepare your second-hand goods and sell them through live meeting!", location: "Online"),
                           
                           activity(title: "Gustav Klimt Exhibition", detail: "Born in 1862, Gustav Klimt was an Austrian painter known for his beautiful, highly decorative works, often exuding an erotic theme. During his time, Klimt was seen as rebellious, since he created paintings that were not in line with academic art – indeed, he created art and lived life on his own terms.", location: "180 St Kilda Rd, Melbourne"),
                           activity(title: "Wonder Woman 1984", detail: "Set in 1984, during the Cold War, the film will follow Diana as she faces off against Maxwell Lord and Cheetah.", location: "Melbourne Central Shopping Centre, Swanston St, Melbourne"),
                           activity(title: "How do I get over a broken heart", detail: "Im freaking out, I need advice, I recently just got out of my first real relationship and it physically hurts to live for real", location: "Online"),
                           activity(title: "Call Me by Your Name ", detail: "We rip out so much of ourselves to be cured of things faster than we should that we go bankrupt by the age of thirty and have less to offer each time we start with someone new. But to feel nothing so as not to feel anything - what a waste", location: "151 Elizabeth, Melbourne"),
                           activity(title: "Humble Rays Melb", detail: " Linguini mushroom in garlic miso butter with lots of parmesan, bonito and onsen egg on top waiting for you to just dig in. Not to mention it was the best selling from our first dine in. I bet you gonna like it!", location: "71 Bouverie Street,Carlton, Melbourne")
                           ]
        
        let actCats = ["Sports" , "ESports", "Recreation", "Movie", "Learning", "Food"]
        
        // -----------------------------------------
        func uploadImage(from image: UIImage, to cloudName: String) {
            let storageRef = storage.reference()
            let activityImageRef = storageRef.child("activity-images")
            
            let cloudFileRef = activityImageRef.child(cloudName)
            
            guard let data = image.jpegData(compressionQuality: 0.5) else { return }  // data: image to be uploaded
            
            let _ = cloudFileRef.putData(data, metadata: nil) { metadata, error in
                guard let _ = metadata else { return }  // if metadata is nil, return
                
                print("Success upload image \(cloudName)")
            }
        }
        
        
        for i in 0...(activities.count - 1) {
            
            let imageName = "act" + String(i)
            let image = UIImage(named: imageName)
            let actRef = db.collection(K.FStore.act).document()
            
            // _. seed image
            uploadImage(from: image!, to: actRef.documentID)
            
            // _. seed activity
            let actCreatorId = actCreatorIds.randomElement()!
            
            // __. Location
            let lat = CLLocationDegrees(-37.8043211841168 + Double(Int.random(in: 0...10000) - 5000) / 50000 )
            let lon = CLLocationDegrees(144.9656667785954 + Double(Int.random(in: 0...10000) - 5000) / 50000 )
            
            var geoPoint: GeoPoint?
            geoPoint = GeoPoint.init(latitude: lat, longitude: lon)
            
            let readDic = [actCreatorId: 1]
            let join = [actCreatorId]
            
            actRef.setData([
                "actTitle": activities[i].title,
                "actDetail": activities[i].detail,
                "createDate": Date() as Any,
                "startDate": Date().advanced(by: TimeInterval(60*Int.random(in: 60...300))) as Any,
                "endDate": Date().advanced(by: TimeInterval(60*Int.random(in: 300...900))) as Any,
                "location": geoPoint as Any,
                "locationString": activities[i].location as Any,
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
