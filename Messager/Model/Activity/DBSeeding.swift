//
//  DBSeeding.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import Foundation
import Firebase

struct DBSeeding {
    let db = Firestore.firestore()
    let storage = Storage.storage()

    init(_ doSeed: Bool) {

        if doSeed {
            seedActivity()
        }
    }

    // MARK:
    func uploadImage(from fileName: String, to cloudName: String) {
        // 1. Cloud Storage Reference
        let storageRef = storage.reference()
        let activityImageRef = storageRef.child("activity-images")
        let cloudFileRef = activityImageRef.child(cloudName)
        print(cloudFileRef)

        // 2. Convert image to Data()
        guard let data = UIImage(named: fileName)?.jpegData(compressionQuality: 1) else {
            fatalError("")
        }

        // 3. Upload the file to the path "activity-images/_"
        let uploadTask = cloudFileRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                fatalError("metadata error?")
            }

            print("Success upload image \(fileName)")

            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print(size)

            // You can also access to download URL after upload.
            cloudFileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
    }

    func getUserUid(by name: String) {
        let usersRef = db.collection(K.FStore.user)

        let query = usersRef.whereField("username", isEqualTo: name)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        print("Query finished")
    }

    func seedActivity() {
        let names = ["Alice", "Bob", "Clara", "Dave", "Ella"]
        let actNames = ["漫威复仇者", "队长小翼 新秀崛起",
                        "刀剑神域", "Survivalists!!!", "女神异闻录５"]
        let actDetails = [ "单人战役模式需要一次性网络连接；多人游戏及下载上线后,内容需要网络连接。",
                           "深受追捧的《队长小翼》漫画在全球范围内依旧热度不减",
                           "世界绝不会忘记",
                           "全世界累计销量突破320万份的《___》，以系列首次的动作RPG形式登场。！",
                           "精彩刺激", "最高质素"
        ]

        for i in 0...9 {

            let imageName = "port" + String(i)
            let userRef = db.collection(K.FStore.user).document()
            let actRef = db.collection(K.FStore.act).document()

            // seed user
            userRef.setData(["username": names.randomElement()!]) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("User Document added with ID: \(userRef.documentID)")
                }
            }

            // seed image
            uploadImage(from: imageName, to: actRef.documentID)

            // seed activity
            let actName = actNames.randomElement()! + String(Int.random(in: 1000...2000))
            let actDetail = actDetails.randomElement()! + String(Int.random(in: 1000...2000))
            let act = Activity(uid: actRef.documentID, userId:
                                userRef.documentID, createDate: Date().timeIntervalSince1970,
                               actTitle: actName, actDetail: actDetail,
                               imageId: actRef.documentID)

            
            do {
                try actRef.setData(from: act)
                print("Activity Document added with ID: \(actRef.documentID)")
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }

        }
    }

}
