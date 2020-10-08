//
//  DBSeeding.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import Foundation
import Firebase

class DBSeeding {
    let db = FireStore.firestore()
    var activity: Activity
    
    
    
    
    func seedUser() {
        names = ["Alice", "Bob", "Clara", "Dave", "Ella"]
        
        for name in names {
            let userRef = db.collection(K.FStore.user).document()
            userRef.setData(["name": name]) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document added with ID: \(userRef!.documentID)")
                }
            }
        }
    }
    
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
    
    func seedImage() {
        for i in 0...9 {
            fileName = "port" + String(i)
            uploadImage(from: fileName, to: fileName)
        }
    }
    
    func seedActivity() {
        for i in range 0...20 {
            
        }
    }
    
}
